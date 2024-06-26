import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;

  bool get isSuccessful => _isSuccessful;

  String? get uid => _uid;

  String? get phoneNumber => _phoneNumber;

  UserModel? get userModel => _userModel;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

//TODO:Check  authentication state
  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;

    await Future.delayed(const Duration(seconds: 2));
    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;

      //TODO:get user data from firebase
      await getUserDataFromFireStore();
      //Save user data to Firebase
      await saveUserDataToSharedPreferences();
      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
  }

  //TODO:Check if user exists
  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    return documentSnapshot.exists;
  }

  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =
        UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      Constants.userModel,
      jsonEncode(userModel!.toMap()),
    );
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    _userModel = UserModel.fromMap(jsonDecode(userModelString));
    notifyListeners();
  }

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        _isLoading = false;
        notifyListeners();
        Navigator.of(context).pushNamed(
          Constants.otpScreen,
          arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );
    await _auth.signInWithCredential(credential).then((value) async {
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    }).catchError((e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    });
  }

  void saveUserDataToFireBase({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function onFail,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (fileImage != null) {
        String imageUrl = await storeFileToStorage(
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}');
        userModel.image = imageUrl;
      }
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
      userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
      _userModel = userModel;
      _uid = userModel.uid;

      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    UploadTask uploadTask = _storage.ref().child(reference).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String fileUrl = await taskSnapshot.ref.getDownloadURL();
    return fileUrl;
  }

  //TODO:get user Stream:ProfileScreen
  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

//TODO:Get  all user stream
  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  //TODO:Send friends request
  Future<void> sendFriendRequest({required String friendID}) async {
    try {
// add our uid  to friend request list
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });
//add friend  uid  to our friend request send list
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> cancelFriendRequest({required String friendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

//TODO:Accept friends request
  Future<void> acceptFriendRequest({required String friendID}) async {
    //add our uid to friend list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
    });
    //add friend uid to friend list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
    });
    //remove our uid from friend request send list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsRequestsUIDs: FieldValue.arrayRemove([friendID]),
    });

    //remove friend uid from friend request list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.sendRequestsUIDs: FieldValue.arrayRemove([_uid]),
    });
  }
  //TODO:Remove friend unfree
  Future<void> removeFriend({required String friendID}) async {
    // remove our uid from friend list
    await _firestore.collection(Constants.users).doc(friendID).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
    });
    // remove friend uid from friend list
    await _firestore.collection(Constants.users).doc(_uid).update({
      Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
    });
  }
  //TODO:Get a list of friends
  Future<List<UserModel>> getFriendsList(String uid) async {
    List<UserModel> friendList = [];
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(uid).get();
    List<dynamic> friendsUIDs = documentSnapshot.get(Constants.friendsUIDs);
    for(String friendsUID in friendsUIDs){
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendsUID)
          .get();
     UserModel friend  = UserModel.fromMap(documentSnapshot.data() as Map<String,dynamic>);
     friendList.add(friend);
    }
    return friendList;
  }
  //TODO:Get a list of friend requests
  Future<List<UserModel>> getFriendRequestsList(String uid) async {
    List<UserModel> friendRequestList = [];
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(uid).get();
    List<dynamic> friendRequestsUIDs = documentSnapshot.get(Constants.friendsRequestsUIDs);
    for(String friendRequestsUID in friendRequestsUIDs){
      DocumentSnapshot documentSnapshot = await _firestore
          .collection(Constants.users)
          .doc(friendRequestsUID)
          .get();
      UserModel friend  = UserModel.fromMap(documentSnapshot.data() as Map<String,dynamic>);
      friendRequestList.add(friend);
    }
    return friendRequestList;
  }
  //TODO:get list of friend requests
  Future<List<DocumentSnapshot>> getFriendRequestList() async {
    List<DocumentSnapshot> friendList = [];
    QuerySnapshot querySnapshot = await _firestore
        .collection(Constants.users)
        .where(Constants.friendsRequestsUIDs, arrayContains: [_uid])
        .get();
    querySnapshot.docs.forEach((element) {
      friendList.add(element);
    });
    return friendList;
  }

  Future logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }
}
