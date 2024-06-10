import 'dart:io';

import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/assets_manager.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:chatapp_firebase/widgets/app_bar_back-button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

//TODO:Sử lí chức năng chọn ảnh
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
    //TODO:Crop  image
   await cropImage(finalFileImage?.path);
   popContext();
  }
  popContext(){
    Navigator.pop(context);
  }

 Future <void> cropImage(filePath) async {
//Crop image
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      // popTheDialog();
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      } else {
        // popTheDialog();
      }
    }
  }

  //dialog
  popTheDialog() {
    Navigator.of(context).pop();
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
                    title: Text('Máy ảnh'),
                  ),
                  ListTile(
                    onTap: () {
                      selectImage(false);
                      Navigator.of(context).pop();
                    },
                    leading: const Icon(Icons.image),
                    title: Text('Thư viện'),
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
        title: Text("Thêm Thông Tin Cá Nhân"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              //TODO:su li chon anh
              finalFileImage == null
                  ? Stack(
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(AssetsManager.userImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            //TO:Sử lí hành động
                            onTap: () {
                              showBottomSheet();
                            },
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              FileImage(File(finalFileImage!.path)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () {
                              showBottomSheet();
                            },
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    //TODO:Save user information
                    if (_nameController.text.isNotEmpty ||
                        _nameController.text.length < 3) {
                      showSnackBar(context, 'Please  enter your name');
                      _btnController.reset();
                      return;
                    }
                    //TODO:Save user information
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

  //TODO:save data  to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    UserModel userModel = UserModel(
        uid: authProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: authProvider.phoneNumber!,
        image: '',
        token: '',
        aboutMe: 'App chat đa câcps đây hahhahaa',
        lastSeen: '',
        createdAt: '',
        isOnline: true,
        friendsUIDs: [],
        friendsRequestsUIDs: [],
        sendRequestsUIDs: []);
    authProvider.saveUserDataToFireBase(
        userModel: userModel,
        fileImage: finalFileImage,
        onSuccess: () async{
          _btnController.success();
         //save user data to firestore to shared preferences
          await authProvider.saveUserDataToSharedPreferences();
          navigateToHomeScreen();
        },
        onFail: () async {
          _btnController.error();
          await Future.delayed(const Duration(seconds: 1));
          _btnController.reset();
        });
  }

  void navigateToHomeScreen() {
// navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(Constants.homeScreen,
        (router)=>false);
  }
}
