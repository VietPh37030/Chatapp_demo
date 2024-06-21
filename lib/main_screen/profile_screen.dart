

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/authentication_provider.dart'; // Import provider for user data
import '../constants.dart'; // Import app constants
import '../models/user_model.dart'; // Import user model
import '../utilities/global_methods.dart'; // Import global utility methods
import '../widgets/app_bar_back-button.dart'; // Import custom app bar back button

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại từ Provider
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Lấy user ID từ arguments được truyền qua route
    final uid = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        // Nút back trên app bar
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text("Thông Tin Cá Nhân"), // Tiêu đề trang
        actions: [
          // Hiển thị nút cài đặt nếu đang xem trang của chính mình
          if (currentUser.uid == uid)
            IconButton(
              onPressed: () async {
                // Điều hướng tới màn hình cài đặt khi nhấn nút cài đặt
                await Navigator.pushNamed(context, Constants.settingsScreen,
                    arguments: uid);
              },
              icon: const Icon(Icons.settings), // Icon cài đặt
            ),
        ],
      ),
      body: StreamBuilder(
        // Stream để lấy dữ liệu người dùng từ Firestore
        stream: context.read<AuthenticationProvider>().userStream(userID: uid),
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
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              children: [
                Center(
                  child: userImageWidget(
                    imageUrl: userModel.image,
                    radius: 50,
                    onTap: () {
                      // Xử lý khi nhấn vào ảnh đại diện
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  userModel.name,
                  style: GoogleFonts.openSans(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 7),
                Text(
                  userModel.phoneNumber,
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                // Widget nút yêu cầu kết bạn
                buildFriendRequestButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 7),
                // Widget nút kết bạn
                buildFriendButton(
                    currentUser: currentUser, userModel: userModel),
                const SizedBox(height: 7),
                // Phần thông tin "About me"
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
                      'Thông tin về tôi',
                      style: GoogleFonts.openSans(
                          fontSize: 22, fontWeight: FontWeight.w600),
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
                  style: GoogleFonts.openSans(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget cho nút yêu cầu kết bạn
  Widget buildFriendRequestButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid &&
        userModel.friendsRequestsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Xử lý khi nhấn vào nút yêu cầu kết bạn
        },
        label: 'Xem yêu cầu kết bạn', width: MediaQuery.of(context).size.width * 0.7,
      );
    } else {
      return const SizedBox
          .shrink(); // Trả về widget rỗng nếu không có yêu cầu kết bạn
    }
  }

  // Widget cho nút kết bạn
  Widget buildFriendButton({
    required UserModel currentUser,
    required UserModel userModel,
  }) {
    if (currentUser.uid == userModel.uid && userModel.friendsUIDs.isNotEmpty) {
      return buildElevatedButton(
        onPressed: () {
          // Xử lý khi nhấn vào nút xem bạn bè
        },
        label: 'Xem bạn bè', width: MediaQuery.of(context).size.width * 0.7,
      );
    } else if (currentUser.uid != userModel.uid) {
      // Hiển thị nút gửi yêu cầu kết bạn hoặc hủy yêu cầu kết bạn
      String label = '';
      if (userModel.friendsRequestsUIDs.contains(currentUser.uid)) {
        return buildElevatedButton(
          onPressed: () async {
            // Xử lý khi nhấn vào nút gửi hoặc hủy yêu cầu kết bạn
            await context
                .read<AuthenticationProvider>()
                .cancelFriendRequest(friendID: userModel.uid)
                .whenComplete(() {
              showSnackBar(context, 'Đã hủy yêu cầu kết bạn');
            });
          },
          label: 'Hủy yêu cầu', width: MediaQuery.of(context).size.width * 0.7,
        );
      } else if (userModel.sendRequestsUIDs.contains(currentUser.uid)) {
        return
            buildElevatedButton(
              onPressed: () async {
                // Xử lý khi nhấn vào nút gửi hoặc hủy yêu cầu kết bạn
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'Bạn đã là bạn của ${userModel.name}');
                });
              },
              label: 'Chấp nhận lời mời', width: MediaQuery.of(context).size.width * 0.7,

        );
      } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildElevatedButton(
              onPressed: () async {
               //Hiênr thị dialog hủy kết bạn
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Center(child: Text('Xác nhận ')),
                      content: Text('Bạn muốn hủy kết bạn voi ${userModel.name}?',textAlign: TextAlign.center,),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng dialog
                          },
                          child: const Text("Cancle"),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Thực hiện hủy kết bạn
                            Navigator.of(context).pop(); // Đóng dialog
                            await context
                                .read<AuthenticationProvider>()
                                .removeFriend(friendID: userModel.uid)
                                .whenComplete(() {
                              showSnackBar(context, 'Đã huỷ bạn bè');
                            });
                          },
                          child: const Text('Hủy kết bạn'),
                        ),
                      ],
                    );
                  },
                );
              },
              label: 'Huỷ kết bạn',
              width: MediaQuery.of(context).size.width * 0.4, // Giảm chiều rộng
            ),
            buildElevatedButton(
              onPressed: () {
                // TODO: Implement send message functionality
                // Ví dụ: Chuyển hướng đến màn hình chat
              },
              label: 'Gửi tin nhắn',
              width: MediaQuery.of(context).size.width * 0.4, // Giảm chiều rộng
            ),
          ],
        );
      } else {
        return buildElevatedButton(
          onPressed: () async {
            // Xử lý khi nhấn vào nút gửi hoặc hủy yêu cầu kết bạn
            await context
                .read<AuthenticationProvider>()
                .sendFriendRequest(friendID: userModel.uid)
                .whenComplete(() {
              showSnackBar(context, 'Đã gửi yêu cầu kết bạn');
            });
          },
          label: 'Gửi lời mời🖖',  width: MediaQuery.of(context).size.width * 0.7);

      }

      // Widget nút gửi hoặc hủy yêu cầu kết bạn
    } else {
      return const SizedBox
          .shrink(); // Trả về widget rỗng nếu là người dùng hiện tại
    }
  }

  // Widget cho nút ElevatedButton được tái sử dụng
  Widget buildElevatedButton({
    required VoidCallback onPressed,
    required String label,
    required double width,
  }) {
    Color buttonColor = Colors.red; // Mặc định màu đỏ cho nút

    // Kiểm tra label để thiết lập màu sắc cho nút
    if (label == 'Gửi lời mời🖖') {
      buttonColor = Colors.green; // Màu xanh lá cây cho nút gửi lời mời
    }
    if (label == 'Xem yêu cầu kết bạn') {
      buttonColor = Colors.purpleAccent;
    }
    if (label == 'Gửi tin nhắn') {
      buttonColor = Colors.green;
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, // Màu chữ của nút
          backgroundColor: buttonColor, // Màu nền của nút
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bo tròn góc của nút
          ),
          padding: EdgeInsets.symmetric(vertical: 16), // Lề của nút
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white, // Màu chữ của văn bản
          ),
        ),
      ),
    );
  }
}
