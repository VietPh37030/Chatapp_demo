import 'package:flutter/material.dart';

class SettingsSwitchListTile extends StatelessWidget {
  const SettingsSwitchListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.containerColor,
    required this.value,
    required this.onChanged,
  });

  final String title; // Tiêu đề của tile
  final String subtitle; // Phụ đề của tile
  final IconData icon; // Biểu tượng bên cạnh tile
  final Color containerColor; // Màu nền cho vùng chứa biểu tượng
  final bool value; // Giá trị hiện tại của switch (bật/tắt)
  final Function(bool) onChanged; // Hàm callback khi switch thay đổi giá trị

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600), // Kiểu chữ đậm cho tiêu đề
        ),
        subtitle: Text(subtitle), // Hiển thị phụ đề
        secondary: Container(
          decoration: BoxDecoration(
            color: containerColor, // Màu nền của container chứa biểu tượng
            borderRadius: BorderRadius.circular(10), // Bo góc cho container
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              color: Colors.white, // Màu biểu tượng
            ),
          ),
        ),
        value: value, // Giá trị hiện tại của switch
        onChanged: (value) {
          onChanged(value); // Gọi hàm callback khi switch thay đổi giá trị
        },
      ),
    );
  }
}
