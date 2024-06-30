import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart'; // Import các hằng số
import '../providers/authentication_provider.dart'; // Import provider cho xác thực người dùng
import '../providers/group_provider.dart'; // Import provider cho dữ liệu nhóm

class GroupMembers extends StatelessWidget {
  const GroupMembers({
    super.key,
    required this.membersUIDs,
  });

  final List<String> membersUIDs; // Danh sách UID của các thành viên trong nhóm

  @override
  Widget build(BuildContext context) {
    // Hàm để lấy tên đã được định dạng
    String getFormatedNames(List<String> names) {
      List<String> newNamesList = names.map((e) {
        return e == context.read<AuthenticationProvider>().userModel!.name
            ? 'Bạn' // Thay thế tên của người dùng hiện tại bằng "You"
            : e;
      }).toList();
      return newNamesList.length == 2
          ? '${newNamesList[0]} và ${newNamesList[1]}' // Nếu có 2 tên thì sử dụng "và"
          : newNamesList.length > 2
          ? '${newNamesList.sublist(0, newNamesList.length - 1).join(', ')} và ${newNamesList.last}' // Nếu có nhiều hơn 2 tên, sử dụng dấu phẩy và "và"
          : newNamesList.first; // Nếu chỉ có một tên thì hiển thị tên đầu tiên
    }

    return StreamBuilder(
      stream: context
          .read<GroupProvider>()
          .streamGroupMembersData(membersUIDs: membersUIDs), // Stream để lấy dữ liệu thành viên nhóm từ Firestore
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi')); // Hiển thị thông báo khi có lỗi xảy ra
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox()); // Hiển thị widget rỗng khi đang chờ dữ liệu
        }

        final members = snapshot.data; // Danh sách các thành viên từ snapshot

        // Lấy danh sách các tên
        final List<String> names = [];
        // Duyệt qua các thành viên để lấy tên
        for (var member in members!) {
          names.add(member[Constants.name]); // Thêm tên của thành viên vào danh sách tên
        }

        return Text(
          getFormatedNames(names), // Hiển thị danh sách tên đã được định dạng
          maxLines: 1, // Số dòng tối đa
          overflow: TextOverflow.ellipsis, // Xử lý khi vượt quá kích thước hiển thị
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w300), // Style của văn bản
        );
      },
    );
  }
}
