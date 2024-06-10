import 'dart:io';

import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/assets_manager.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:chatapp_firebase/widgets/app_bar_back-button.dart';
import 'package:chatapp_firebase/widgets/display_user_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();

  File? finalFileImage;
  String userImage = '';

  @override
  void dispose() {
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
        fromCamera: fromCamera,
        onFail: (String message) {
          showSnackBar(context, message);
        });
     cropImage(finalFileImage?.path);
  }

  popContext() {
    Navigator.pop(context);
  }

  void cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: MediaQuery.of(context).size.height / 6,
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  selectImage(true);
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text('Máy ảnh'),
              ),
              ListTile(
                onTap: () {
                  selectImage(false);
                  Navigator.of(context).pop();
                },
                leading: const Icon(Icons.image),
                title: const Text('Thư viện'),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: const Text("Thêm Thông Tin Cá Nhân"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
          DisplayUserImage(finalFileImage: finalFileImage, radius: 60, onPressed: (){
            showBottomSheet();
          }),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Mời Nhập Tên',
                  labelText: 'Họ Tên',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _nameController.text.length < 3) {
                      showSnackBar(context, 'Please enter your name');
                      _btnController.reset();
                      return;
                    }
                    saveUserDataToFireStore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
        uid: authProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: authProvider.phoneNumber!,
        image: '',
        token: '',
        aboutMe: 'App chat đa cấp đây hahhahaa',
        lastSeen: '',
        createdAt: '',
        isOnline: true,
        friendsUIDs: [],
        friendsRequestsUIDs: [],
        sendRequestsUIDs: []);

    authProvider.saveUserDataToFireBase(
        userModel: userModel,
        fileImage: finalFileImage,
        onSuccess: () async {
          _btnController.success();
          await authProvider.saveUserDataToSharedPreferences();
          navigateToHomeScreen();
        },
        onFail: (errorMessage) async {
          _btnController.error();
          showSnackBar(context, errorMessage);
          await Future.delayed(const Duration(seconds: 1));
          _btnController.reset();
        });
  }

  void navigateToHomeScreen() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Constants.homeScreen, (route) => false);
  }
}
