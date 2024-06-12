import 'dart:ui';

import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:chatapp_firebase/widgets/app_bar_back-button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    //get user data from argument
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        //TODO:logout
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text("Thông Tin Cá Nhân"),
        actions: [
          // currentUser.uid == uid?
          IconButton(
            onPressed: () async {
              //Taọ hộp hội thoại khi ta đăng xuat
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text(
                          'Đăng xuất',
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          "Bạn muốn đăng xuất không ?",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                await context
                                    .read<AuthenticationProvider>()
                                    .logout()
                                    .whenComplete(() {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      Constants.loginScreen, (route) => false);
                                });
                              },
                              child: const Text('Đăng Xuất Ngay'))
                        ],
                      ));
            },
            icon: const Icon(Icons.logout),
          )
          // :const SizedBox(),
        ],
      ),
      body: StreamBuilder(
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userModel =
              UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                      imageUrl: userModel.image, radius: 50, onTap: () {}),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  userModel.phoneNumber,
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                buildFriendRequestButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(
                  height: 7,
                ),
                buildFriendButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(
                  height: 7,
                ),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.w500),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  //friend request button
  Widget buildFriendRequestButton(
      {required UserModel currentUser, required UserModel userModel}) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendsRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
          onPressed: () {
            //Navigate to friend request screen
          },
          label: 'View Friends Request');
    } else {
      //TODO:Not in profile
      return const SizedBox.shrink();
    }
  }

  // friend button
  Widget buildFriendButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(onPressed: () {},
          label: 'View Friends');
    } else {
      //TODO:Show send  friend request Button
      if (currentUser.uid != userModel.uid) {
        return buildElevatedButton(
            onPressed: () async {
              //TODO:Send friend request
            },
            label: 'Send Friend Request');
      }else{
        return const SizedBox.shrink();
      }

    }
  }

// TODO:send request friend
  Widget buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
