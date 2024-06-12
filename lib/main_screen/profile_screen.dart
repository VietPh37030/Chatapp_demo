import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/widgets/app_bar_back-button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        title: const Text("Thông tin"),
        actions: [
          // currentUser.uid == uid?
          IconButton(
            onPressed: () async {
              //Taọ hộp hội thoại khi ta đăng xuat
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Đăng Xuất'),
                        content:
                            const Text("Bạn có chắc muốn đăng xuất không ?"),
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

          return ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(userModel.image),
            ),
            title: Text(userModel.name),
            subtitle: Text(userModel.aboutMe),
          );
        },
      ),
    );
  }
}
