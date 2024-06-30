import 'package:flutter/material.dart';

import '../providers/group_provider.dart';

class AddMembers extends StatelessWidget {
  const AddMembers({
    Key? key,
    required this.groupProvider,
    required this.isAdmin,
    required this.onPressed,
  }) : super(key: key);

  final GroupProvider groupProvider;
  final bool isAdmin;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '2 Members', // Văn bản tạm thời để hiển thị số lượng thành viên
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        !isAdmin
            ? const SizedBox() // Nếu không phải admin, không hiển thị gì cả
            : Row(
          children: [
            const Text(
              'Thêm thành viên', // Văn bản cho chức năng thêm thành viên
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              child: IconButton(
                onPressed: onPressed, // Hàm sẽ được gọi khi nhấn nút
                icon: const Icon(Icons.person_add), // Biểu tượng thêm thành viên
              ),
            )
          ],
        )
      ],
    );
  }
}
