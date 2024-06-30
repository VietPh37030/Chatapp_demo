import 'package:chatapp_firebase/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';

import '../main_screen/group_settings_screen.dart'; // Import màn hình cài đặt nhóm
import '../providers/group_provider.dart'; // Import provider cho dữ liệu nhóm
import '../utilities/global_methods.dart'; // Import các phương thức tiện ích

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
  });

  final GroupProvider groupProvider; // Provider cho dữ liệu nhóm
  final bool isAdmin; // Biến cờ chỉ ra người dùng hiện tại có phải là quản trị viên không

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            SettingsListTile(
              title: 'Media', // Tiêu đề cho cài đặt phương tiện
              icon: Icons.image, // Biểu tượng cho cài đặt phương tiện
              iconContainerColor: Colors.deepPurple, // Màu cho vùng chứa biểu tượng
              onTap: () {
                // điều hướng đến màn hình phương tiện
                // Điều hướng đến màn hình quản lý phương tiện
              },
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(
              title: 'Cài đặt Nhóm', // Tiêu đề cho cài đặt nhóm
              icon: Icons.settings, // Biểu tượng cho cài đặt nhóm
              iconContainerColor: Colors.deepPurple, // Màu cho vùng chứa biểu tượng
              onTap: () {
                if (!isAdmin) {
                  // hiển thị snackbar
                  showSnackBar(context, 'Chỉ có quản trị viên mới có thể thay đổi cài đặt nhóm');
                } else {
                  groupProvider.updateGroupAdminsList().whenComplete(() {
                    // điều hướng đến màn hình cài đặt nhóm
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupSettingsScreen(),
                      ),
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
