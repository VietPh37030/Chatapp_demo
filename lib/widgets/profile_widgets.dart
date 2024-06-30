import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts để sử dụng font chữ
import 'package:provider/provider.dart'; // Import Provider để quản lý trạng thái

import '../constants.dart';
import '../main_screen/friend_requests_screen.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/group_provider.dart'; // Import Provider cho dữ liệu nhóm
import '../utilities/global_methods.dart'; // Import các phương thức tiện ích

class GroupStatusWidget extends StatelessWidget {
  const GroupStatusWidget({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin; // Biến cờ để xác định người dùng có phải là quản trị viên hay không
  final GroupProvider groupProvider; // Provider cho dữ liệu nhóm

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: !isAdmin
              ? null
              : () {
            // Hiển thị dialog để thay đổi loại nhóm
            showMyAnimatedDialog(
              context: context,
              title: 'Thay đổi loại nhóm',
              content:
              'Bạn có chắc chắn muốn thay đổi loại nhóm thành ${groupProvider.groupModel.isPrivate ? 'Công khai' : 'Riêng tư'}?',
              textAction: 'Thay đổi',
              onActionTap: (value) {
                if (value) {
                  // Thực hiện thay đổi loại nhóm
                  groupProvider.changeGroupType();
                }
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.deepPurple : Colors.grey,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              groupProvider.groupModel.isPrivate ? 'Riêng tư' : 'Công khai',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GetRequestWidget(
          groupProvider: groupProvider,
          isAdmin: isAdmin,
        ),
      ],
    );
  }
}

class ProfileStatusWidget extends StatelessWidget {
  const ProfileStatusWidget({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel; // Thông tin người dùng
  final UserModel currentUser; // Thông tin người dùng hiện tại

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FriendRequestButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
        const SizedBox(height: 10),
        FriendsButton(
          currentUser: currentUser,
          userModel: userModel,
        ),
      ],
    );
  }
}

class FriendsButton extends StatelessWidget {
  const FriendsButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel; // Thông tin người dùng
  final UserModel currentUser; // Thông tin người dùng hiện tại

  @override
  Widget build(BuildContext context) {
    // Button bạn bè
    Widget buildFriendsButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendsUIDs.isNotEmpty) {
        return MyElevatedButton(
          onPressed: () {
            // Điều hướng đến màn hình bạn bè
            Navigator.pushNamed(
              context,
              Constants.friendsScreen,
            );
          },
          label: 'Bạn bè',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        if (currentUser.uid != userModel.uid) {
          // Hiển thị nút Hủy yêu cầu kết bạn nếu người dùng đã gửi yêu cầu kết bạn
          // Ngược lại, hiển thị nút Gửi yêu cầu kết bạn
          if (userModel.friendsRequestsUIDs.contains(currentUser.uid)) {
            // Hiển thị nút Gửi yêu cầu kết bạn
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .cancelFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'Yêu cầu kết bạn đã được hủy');
                });
              },
              label: 'Hủy yêu cầu',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.sendRequestsUIDs
              .contains(currentUser.uid)) {
            // Hiển thị nút Chấp nhận kết bạn
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .acceptFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(
                      context, 'Bạn đã trở thành bạn với ${userModel.name}');
                });
              },
              label: 'Chấp nhận',
              width: MediaQuery.of(context).size.width * 0.4,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          } else if (userModel.friendsUIDs.contains(currentUser.uid)) {
            // Nếu đã là bạn bè, hiển thị nút Hủy kết bạn và Chat
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  onPressed: () async {
                    // Hiển thị dialog xác nhận hủy kết bạn
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(
                          'Hủy kết bạn',
                          textAlign: TextAlign.center,
                        ),
                        content: Text(
                          'Bạn có chắc chắn muốn hủy kết bạn với ${userModel.name}?',
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // Hủy kết bạn
                              await context
                                  .read<AuthenticationProvider>()
                                  .removeFriend(friendID: userModel.uid)
                                  .whenComplete(() {
                                showSnackBar(
                                    context, 'Bạn và ${userModel.name} không còn là bạn bè');
                              });
                            },
                            child: const Text('Đồng ý'),
                          ),
                        ],
                      ),
                    );
                  },
                  label: 'Hủy kết bạn',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Colors.deepPurple,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 10),
                MyElevatedButton(
                  onPressed: () async {
                    // Điều hướng đến màn hình chat với thông tin người dùng
                    Navigator.pushNamed(context, Constants.chatScreen,
                        arguments: {
                          Constants.contactUID: userModel.uid,
                          Constants.contactName: userModel.name,
                          Constants.contactImage: userModel.image,
                          Constants.groupId: ''
                        });
                  },
                  label: 'Chat',
                  width: MediaQuery.of(context).size.width * 0.4,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            );
          } else {
            // Hiển thị nút Gửi yêu cầu kết bạn
            return MyElevatedButton(
              onPressed: () async {
                await context
                    .read<AuthenticationProvider>()
                    .sendFriendRequest(friendID: userModel.uid)
                    .whenComplete(() {
                  showSnackBar(context, 'Yêu cầu kết bạn đã được gửi');
                });
              },
              label: 'Gửi yêu cầu',
              width: MediaQuery.of(context).size.width * 0.7,
              backgroundColor: Theme.of(context).cardColor,
              textColor: Theme.of(context).colorScheme.primary,
            );
          }
        } else {
          return const SizedBox.shrink(); // Nếu là chính người dùng hiện tại, không hiển thị gì cả
        }
      }
    }

    return buildFriendsButton();
  }
}

class FriendRequestButton extends StatelessWidget {
  const FriendRequestButton({
    super.key,
    required this.userModel,
    required this.currentUser,
  });

  final UserModel userModel; // Thông tin người dùng
  final UserModel currentUser; // Thông tin người dùng hiện tại

  @override
  Widget build(BuildContext context) {
    // Button yêu cầu kết bạn
    Widget buildFriendRequestButton() {
      if (currentUser.uid == userModel.uid &&
          userModel.friendsRequestsUIDs.isNotEmpty) {
        // Hiển thị nút Đi tới yêu cầu kết bạn
        return MyElevatedButton(
          onPressed: () {
            // Điều hướng đến màn hình yêu cầu kết bạn
            Navigator.pushNamed(
              context,
              Constants.friendRequestsScreen,
            );
          },
          label: 'Yêu cầu',
          width: MediaQuery.of(context).size.width * 0.4,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).colorScheme.primary,
        );
      } else {
        // Nếu không phải là trang cá nhân của chúng tôi, không hiển thị gì cả
        return const SizedBox.shrink();
      }
    }

    return buildFriendRequestButton();
  }
}

class GetRequestWidget extends StatelessWidget {
  const GetRequestWidget({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider; // Provider cho dữ liệu nhóm
  final bool isAdmin; // Biến cờ để xác định người dùng có phải là quản trị viên hay không

  @override
  Widget build(BuildContext context) {
    // Widget hiển thị yêu cầu
    Widget getRequestWidget() {
      // Kiểm tra nếu người dùng là quản trị viên
      if (isAdmin) {
        // Kiểm tra nếu có yêu cầu tham gia nhóm
        if (groupProvider.groupModel.awaitingApprovalUIDs.isNotEmpty) {
          return InkWell(
            onTap: () {
              // Điều hướng đến màn hình thêm thành viên
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FriendRequestScreen(
                  groupId: groupProvider.groupModel.groupId,
                );
              }));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orangeAccent,
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 15,
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      } else {
        return const SizedBox();
      }
    }

    return getRequestWidget();
  }
}

class MyElevatedButton extends StatelessWidget {
  const MyElevatedButton({
    super.key,
    required this.onPressed,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.textColor,
  });

  final VoidCallback onPressed; // Hàm callback khi nút được nhấn
  final String label; // Nhãn của nút
  final double width; // Độ rộng của nút
  final Color backgroundColor; // Màu nền của nút
  final Color textColor; // Màu chữ của nút

  @override
  Widget build(BuildContext context) {
    // Xây dựng nút ElevatedButton
    Widget buildElevatedButton() {
      return SizedBox(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5, // Độ nâng của nút
            backgroundColor: backgroundColor, // Màu nền của nút
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Bo góc của nút
            ),
          ),
          onPressed: onPressed, // Hàm callback khi nút được nhấn
          child: Text(
            label.toUpperCase(), // Hiển thị nhãn in hoa
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              color: textColor, // Màu chữ của nút
            ),
          ),
        ),
      );
    }

    return buildElevatedButton();
  }
}
