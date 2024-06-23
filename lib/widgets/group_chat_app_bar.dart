import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../utilities/global_methods.dart';

// class GroupChatAppBar extends StatefulWidget {
//   const GroupChatAppBar({super.key, required this.groupId});
//
//   final String groupId;
//
//   @override
//   State<GroupChatAppBar> createState() => _GroupChatAppBarState();
// }
//
// class _GroupChatAppBarState extends State<GroupChatAppBar> {
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       // Stream để lấy dữ liệu người dùng từ Firestore
//       stream: context
//           .read<AuthenticationProvider>()
//           .userStream(userID: widget.groupId),
//       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
//         // Xử lý khi có lỗi trong quá trình lấy dữ liệu
//         if (snapshot.hasError) {
//           return const Center(child: Text('Có lỗi xảy ra'));
//         }
//
//         // Xử lý khi đang chờ lấy dữ liệu
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         // Chuyển dữ liệu từ Firestore thành UserModel
//         final groupModel =
//         GroupModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
//
//         // Hiển thị nội dung trang thông tin cá nhân
//         return  Row(
//           children: [
//             userImageWidget(
//               imageUrl: groupModel.groupImage,
//               radius: 20,
//               onTap: () {
//                //Navigate  tp group setting screen
//               },
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(groupModel.groupName),
//                 const Text(
//                   'Group description or group members',
//                   style: TextStyle(fontSize: 12),
//                 )
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
