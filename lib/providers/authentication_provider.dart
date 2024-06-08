import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print('navigator to otp');
        },
        codeAutoRetrievalTimeout: (String vertificationId) {});
  }
}
