import 'package:date_format/date_format.dart'; // Nhập gói date_format để định dạng ngày tháng
import 'package:flutter/material.dart'; // Nhập gói material.dart cho các thành phần giao diện Flutter

import 'package:provider/provider.dart'; // Nhập gói provider để quản lý trạng thái

import '../enum/enums.dart'; // Nhập enums.dart cho các enum tùy chỉnh
import '../models/user_model.dart'; // Nhập user_model.dart cho mô hình dữ liệu người dùng
import '../providers/authentication_provider.dart'; // Nhập authentication_provider.dart cho logic xác thực
import '../providers/group_provider.dart'; // Nhập group_provider.dart cho logic quản lý nhóm
import '../widgets/friend_widget.dart'; // Nhập friend_widget.dart cho giao diện hiển thị bạn bè
import '../widgets/settings_list_tile.dart'; // Nhập settings_list_tile.dart cho danh sách các mục cài đặt tùy chỉnh
import '../widgets/settings_switch_list_tile.dart'; // Nhập settings_switch_list_tile.dart cho danh sách các mục chuyển đổi cài đặt

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({Key? key}); // Constructor cho widget GroupSettingsScreen

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState(); // Tạo trạng thái cho GroupSettingsScreen
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  // Phương thức lấy tên các quản trị nhóm dựa trên groupProvider và UID người dùng
  String getGroupAdminsNames({
    required GroupProvider groupProvider,
    required String uid,
  }) {
    // Kiểm tra nếu không có thành viên nhóm
    if (groupProvider.groupMembersList.isEmpty) {
      return 'Để chỉ định vai trò Quản trị viên, vui lòng thêm thành viên vào màn hình trước'; // Trả về thông báo nếu không có thành viên nhóm
    } else {
      List<String> groupAdminsNames = []; // Khởi tạo danh sách để lưu tên các quản trị viên

      // Lấy danh sách các quản trị viên nhóm
      List<UserModel> groupAdminsList = groupProvider.groupAdminsList;

      // Ánh xạ các quản trị viên thành tên, hiển thị 'Bạn' cho trạng thái quản trị viên của người dùng hiện tại
      List<String> groupAdminsNamesList = groupAdminsList.map((groupAdmin) {
        return groupAdmin.uid == uid ? 'Bạn' : groupAdmin.name;
      }).toList();

      // Thêm các tên đã ánh xạ vào danh sách groupAdminsNames
      groupAdminsNames.addAll(groupAdminsNamesList);

      // Định dạng hiển thị tên dựa trên số lượng
      return groupAdminsNames.length == 2
          ? '${groupAdminsNames[0]} và ${groupAdminsNames[1]}' // Hiển thị hai tên
          : groupAdminsNames.length > 2
          ? '${groupAdminsNames.sublist(0, groupAdminsNames.length - 1).join(', ')} và ${groupAdminsNames.last}' // Hiển thị nhiều hơn hai tên
          : 'Bạn'; // Hiển thị 'Bạn' nếu chỉ có một tên
    }
  }

  // Lấy màu nền container cho danh sách quản trị viên dựa trên groupProvider
  Color getAdminsContainerColor({
    required GroupProvider groupProvider,
  }) {
    // Kiểm tra nếu không có thành viên nhóm
    if (groupProvider.groupMembersList.isEmpty) {
      return Theme.of(context).disabledColor; // Trả về màu vô hiệu hóa nếu không có thành viên nhóm
    } else {
      return Theme.of(context).cardColor; // Trả về màu thẻ mặc định nếu có thành viên nhóm
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy danh sách các quản trị viên nhóm
    List<UserModel> groupAdminsList =
        context.read<GroupProvider>().groupAdminsList;

    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Cài đặt Nhóm'),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: Column(
              children: [
                SettingsSwitchListTile(
                  title: 'Chỉnh sửa Cài đặt Nhóm',
                  subtitle:
                  'Chỉ có Quản trị viên mới có thể thay đổi thông tin nhóm, tên, hình ảnh và mô tả',
                  icon: Icons.edit,
                  containerColor: Colors.green,
                  value: groupProvider.groupModel.editSettings,
                  onChanged: (value) {
                    groupProvider.setEditSettings(value: value);
                  },
                ),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                  title: 'Phê duyệt Thành viên Mới',
                  subtitle:
                  'Thành viên mới sẽ chỉ được thêm sau khi được phê duyệt bởi quản trị viên',
                  icon: Icons.approval,
                  containerColor: Colors.blue,
                  value: groupProvider.groupModel.approveMembers,
                  onChanged: (value) {
                    groupProvider.setApproveNewMembers(value: value);
                  },
                ),
                const SizedBox(height: 10),
                groupProvider.groupModel.approveMembers
                    ? SettingsSwitchListTile(
                  title: 'Yêu cầu Tham gia',
                  subtitle:
                  'Yêu cầu các thành viên mới tham gia nhóm trước khi xem nội dung nhóm',
                  icon: Icons.request_page,
                  containerColor: Colors.orange,
                  value: groupProvider.groupModel.requestToJoing,
                  onChanged: (value) {
                    groupProvider.setRequestToJoin(value: value);
                  },
                )
                    : const SizedBox.shrink(),
                const SizedBox(height: 10),
                SettingsSwitchListTile(
                  title: 'Khóa Tin Nhắn',
                  subtitle:
                  'Chỉ có Quản trị viên mới có thể gửi tin nhắn, các thành viên khác chỉ có thể đọc tin nhắn',
                  icon: Icons.lock,
                  containerColor: Colors.deepPurple,
                  value: groupProvider.groupModel.lockMessages,
                  onChanged: (value) {
                    groupProvider.setLockMessages(value: value);
                  },
                ),
                const SizedBox(height: 10),
                Card(
                  color: getAdminsContainerColor(groupProvider: groupProvider),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: SettingsListTile(
                      title: 'Quản trị viên Nhóm',
                      subtitle: getGroupAdminsNames(
                          groupProvider: groupProvider, uid: uid),
                      icon: Icons.admin_panel_settings,
                      iconContainerColor: Colors.red,
                      onTap: () {
                        // Kiểm tra nếu không có thành viên nhóm
                        if (groupProvider.groupMembersList.isEmpty) {
                          return;
                        }
                        // Hiển thị bottom sheet để chọn quản trị viên
                        showBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.9,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Chọn Quản trị viên Nhóm',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Hoàn tất',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: groupProvider
                                            .groupMembersList.length,
                                        itemBuilder: (context, index) {
                                          final friend = groupProvider
                                              .groupMembersList[index];
                                          return FriendWidget(
                                            friend: friend,
                                            viewType: FriendViewType.groupView,
                                            isAdminView: true,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
