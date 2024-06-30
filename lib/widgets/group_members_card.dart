import 'package:flutter/material.dart';

import '../models/user_model.dart'; // Import model UserModel
import '../providers/group_provider.dart'; // Import provider GroupProvider
import '../utilities/global_methods.dart'; // Import global utility methods

class GoupMembersCard extends StatefulWidget {
  const GoupMembersCard({
    super.key,
    required this.isAdmin,
    required this.groupProvider,
  });

  final bool isAdmin; // Biến để xác định người dùng có phải là quản trị viên hay không
  final GroupProvider groupProvider; // Provider để cung cấp dữ liệu nhóm

  @override
  State<GoupMembersCard> createState() => _GoupMembersCardState(); // Override createState để tạo State cho widget
}

class _GoupMembersCardState extends State<GoupMembersCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Độ nâng cao của Card
      child: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future: widget.groupProvider.getGroupMembersDataFromFirestore(
              isAdmin: false, // Truyền isAdmin=false để lấy dữ liệu thành viên nhóm (không phải admin)
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(), // Hiển thị tiến trình đang chờ khi đang tải dữ liệu
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'), // Hiển thị thông báo khi có lỗi xảy ra
                );
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Không có thành viên nào'), // Hiển thị thông báo khi không có thành viên nào trong nhóm
                );
              }
              return ListView.builder(
                  shrinkWrap: true, // Thu gọn ListView để phù hợp với nội dung
                  physics: const NeverScrollableScrollPhysics(), // Vô hiệu hóa scroll của ListView
                  itemCount: snapshot.data!.length, // Số lượng thành viên trong danh sách
                  itemBuilder: (context, index) {
                    final member = snapshot.data![index]; // Lấy thông tin của thành viên tại vị trí index
                    return ListTile(
                      contentPadding: EdgeInsets.zero, // Đặt padding của nội dung trong ListTile
                      leading: userImageWidget( // Widget hiển thị hình ảnh của thành viên
                          imageUrl: member.image, radius: 40, onTap: () {}), // Truyền hình ảnh, bán kính và hành động khi nhấn vào ảnh
                      title: Text(member.name), // Hiển thị tên thành viên
                      subtitle: Text(member.aboutMe), // Hiển thị mô tả về thành viên
                      trailing: widget.groupProvider.groupModel.adminsUIDs
                          .contains(member.uid)
                          ? const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.orangeAccent,
                      )
                          : const SizedBox(), // Hiển thị biểu tượng admin nếu thành viên là admin của nhóm
                      onTap: !widget.isAdmin
                          ? null
                          : () {
                        // Xử lý sự kiện khi nhấn vào thành viên (chỉ admin mới có quyền)
                        showMyAnimatedDialog(
                          context: context,
                          title: 'Xóa thành viên', // Tiêu đề của dialog xác nhận
                          content:
                          'Bạn có chắc muốn xóa ${member.name} khỏi nhóm không?', // Nội dung xác nhận
                          textAction: 'Xóa', // Chữ "Remove" trên nút xác nhận
                          onActionTap: (value) async {
                            if (value) {
                              // Nếu người dùng xác nhận muốn xóa thành viên
                              await widget.groupProvider
                                  .removeGroupMember(
                                groupMember: member, // Gọi phương thức xóa thành viên từ nhóm
                              );

                              setState(() {}); // Cập nhật lại giao diện sau khi xóa thành viên
                            }
                          },
                        );
                      },
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
