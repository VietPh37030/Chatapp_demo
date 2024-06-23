import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../utilities/global_methods.dart';

class ChatAppBar extends StatefulWidget {
  const ChatAppBar({super.key, required this.contactUID});

  final String contactUID;

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Stream để lấy dữ liệu người dùng từ Firestore
      stream: context
          .read<AuthenticationProvider>()
          .userStream(userID: widget.contactUID),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        // Xử lý khi có lỗi trong quá trình lấy dữ liệu
        if (snapshot.hasError) {
          return const Center(child: Text('Có lỗi xảy ra'));
        }

        // Xử lý khi đang chờ lấy dữ liệu
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Chuyển dữ liệu từ Firestore thành UserModel
        final userModel =
        UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        // Hiển thị nội dung trang thông tin cá nhân
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                userImageWidget(
                  imageUrl: userModel.image,
                  radius: 20,
                  onTap: () {
                    Navigator.pushNamed(context, Constants.profileScreen,
                        arguments: userModel.uid);
                  },
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userModel.name,style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),),
                     Text(
                      'Online',
                      //UserModel.isOnline ? 'Online' : 'Offline',
                      style:GoogleFonts.openSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    // Thực hiện chức năng chụp ảnh
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () {
                    // Thực hiện chức năng gọi video
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
