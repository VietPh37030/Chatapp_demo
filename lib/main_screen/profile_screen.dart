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

    // Get user data from argument
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        // Logout
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text("Thông Tin Cá Nhân"),
        actions: [
          // Only show settings button if viewing own profile
          if (currentUser.uid == uid)
            IconButton(
              onPressed: () async {
                // Navigate to settings screen
                await Navigator.pushNamed(context, Constants.settingsScreen, arguments: uid);
              },
              icon: const Icon(Icons.settings),
            ),
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

          final userModel = UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 50,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 7),
                Text(
                  userModel.phoneNumber,
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                buildFriendRequestButton(currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 7),
                buildFriendButton(currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(color: Colors.grey, thickness: 1),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About me',
                      style: GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: Divider(color: Colors.grey, thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  userModel.aboutMe,
                  style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Friend request button
  Widget buildFriendRequestButton({required UserModel currentUser, required UserModel userModel}) {
    if (currentUser.uid == userModel.uid && userModel.friendsRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Navigate to friend request screen
        },
        label: 'View Friends Request',
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Friend button
  Widget buildFriendButton({required UserModel currentUser, required UserModel userModel}) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Navigate to friends list screen
        },
        label: 'View Friends',
      );
    } else if (currentUser.uid != userModel.uid) {
      // Show send friend request button
      return buildElevatedButton(
        onPressed: () async {
          // Send friend request
        },
        label: 'Send Friend Request',
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // Send request friend
  Widget buildElevatedButton({required VoidCallback onPressed, required String label}) {
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
