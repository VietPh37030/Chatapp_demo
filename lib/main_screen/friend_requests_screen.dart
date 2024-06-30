import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../enum/enums.dart';
import '../widgets/app_bar_back-button.dart';
import '../widgets/friends_list.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key, this.groupId = ''}) : super(key: key);

  final String groupId;

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Nút trở lại tùy chỉnh trong thanh tiêu đề
        leading: AppBarBackButton(
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        centerTitle: true,
        title: const Text('Kết bạn'), // Tiêu đề của màn hình
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // CupertinoSearchTextField để tìm kiếm
            CupertinoSearchTextField(
              placeholder: 'Search', // Placeholder cho ô tìm kiếm
              style: const TextStyle(color: Colors.white), // Màu văn bản
              onChanged: (value) {
                print(value); // Xử lý sự thay đổi đầu vào tìm kiếm
              },
            ),

            Expanded(
              child: FriendsList(
                viewType: FriendViewType.friendRequests, // Hiển thị danh sách yêu cầu kết bạn
                groupId: widget.groupId, // Truyền groupId vào FriendsList
              ),
            ),
          ],
        ),
      ),
    );
  }
}
