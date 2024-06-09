import 'dart:convert';

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
  /// check  if the user  exists
  Future<bool> checkUserExists() async{
   DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(_uid).get();
   if(documentSnapshot.exists){
     return true;
   }else{
     return false;
   }
  }
  //*get user data from FireStore
  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot = await _firestore.collection(Constants.users).doc(_uid).get();
    _userModel =UserModel.fromMap(documentSnapshot.data() as Map<String,dynamic>);
    notifyListeners();
  }
  //save user data to share preferences
  Future<void> saveUserDataToSharedPreferences() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(Constants.userModel, jsonEncode(userModel!.toMap()));
  }
  //get data from share preferences
  Future<void> getUserDataFromSharedPreferences() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString = sharedPreferences.getString(Constants.userModel) ??'';
    _userModel =UserModel.fromMap(jsonDecode(userModelString));
    notifyListeners();
  }


  // sign in with  phone number
  Future<void> signInWithPhoneNumber(
      {required String phoneNumber, required BuildContext context}) async {
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
          // navigate to otp screen
          Navigator.of(context).pushNamed(
            Constants.otpScreen,
            arguments: {
              Constants.verificationId: verificationId,
              Constants.phoneNumber: phoneNumber,
            },
          );
        },
        codeAutoRetrievalTimeout: (String vertificationId) {});
  }

//TODO:verify otp code
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
}