import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../constants.dart';
import '../providers/authentication_provider.dart';
import '../utilities/assets_manager.dart';
import '../utilities/global_methods.dart';


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
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                placeholder: 'Tìm kiếm',
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: context
                    .read<AuthenticationProvider>()
                    .getAllUsersStream(userID: currentUser.uid),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
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
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
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
                          // Điều hướng tới trang hồ sơ của người dùng được chọn
                          Navigator.pushNamed(
                            context,
                            Constants.profileScreen,
                            arguments: document.id, // Đảm bảo rằng bạn đang truyền đúng document.id
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
