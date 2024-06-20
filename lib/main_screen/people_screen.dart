import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../utilities/assets_manager.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
      // Scaffold là khung chính của một trang trong Flutter, cung cấp cấu trúc cơ bản
      body: SafeArea(
        // SafeArea đảm bảo nội dung không bị che bởi các phần tử hệ thống như thanh trạng thái
        child: Column(
          children: [
            //   Cupertino Search bar
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: 'Search',
              ),
            ),
            // Expanded mở rộng widget con để chiếm toàn bộ không gian còn lại của Column
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context
                    .read<AuthenticationProvider>()
                    .getAllUsersStream(userID: currentUser.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Không có người dùng nào được tìm thấy',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Lottie.asset(AssetsManager.sadIcon),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                      return ListTile(
                        leading: userImageWidget(
                          imageUrl: data[Constants.image],
                          radius: 40,
                          onTap: () {},
                        ),
                        title: Text(data[Constants.name]),
                        subtitle: Text(
                          data[Constants.aboutMe],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // Navigate to the selected user's profile
                          Navigator.pushNamed(
                            context,
                            Constants.profileScreen,
                            arguments: document.id,
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
