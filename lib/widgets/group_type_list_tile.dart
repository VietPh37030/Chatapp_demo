import 'package:flutter/material.dart';

import '../enum/enums.dart'; // Import các enum cần thiết

class GroupTypeListTile extends StatelessWidget {
  GroupTypeListTile({
    super.key,
    required this.title, // Tiêu đề của tile
    required this.value, // Giá trị của radio button
    required this.groupValue, // Giá trị của nhóm radio button
    required this.onChanged, // Hàm callback khi giá trị thay đổi
  });

  final String title; // Tiêu đề của tile
  GroupType value; // Giá trị của radio button
  GroupType? groupValue; // Giá trị của nhóm radio button (có thể là null)
  final Function(GroupType?) onChanged; // Hàm callback khi giá trị thay đổi

  @override
  Widget build(BuildContext context) {
    // Viết hoa chữ cái đầu của tiêu đề
    final capitalizedTitle = title[0].toUpperCase() + title.substring(1);
    return RadioListTile<GroupType>(
      value: value, // Giá trị của radio button
      dense: true, // Thiết lập kích thước giao diện mảnh
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Bo tròn góc cho tile
      ),
      tileColor: Colors.grey[200], // Màu nền cho tile
      contentPadding: EdgeInsets.zero, // Độ lề nội dung tile
      groupValue: groupValue, // Giá trị của nhóm radio button
      onChanged: onChanged, // Hàm callback khi giá trị thay đổi
      title: Text(
        capitalizedTitle, // Tiêu đề viết hoa chữ cái đầu
        style: const TextStyle(
          fontWeight: FontWeight.bold, // Kiểu chữ in đậm
        ),
      ),
    );
  }
}
