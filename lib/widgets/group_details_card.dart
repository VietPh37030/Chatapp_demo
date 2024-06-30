import 'package:chatapp_firebase/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts để sử dụng font chữ
import 'package:provider/provider.dart'; // Import Provider để quản lý trạng thái

import '../models/user_model.dart'; // Import UserModel để sử dụng thông tin người dùng
import '../providers/authentication_provider.dart'; // Import AuthenticationProvider để lấy thông tin người dùng hiện tại
import '../providers/group_provider.dart'; // Import GroupProvider để lấy thông tin nhóm
import '../utilities/global_methods.dart'; // Import các phương thức tiện ích

class InfoDetailsCard extends StatelessWidget {
  const InfoDetailsCard({
    super.key,
    this.groupProvider,
    this.isAdmin,
    this.userModel,
  });

  final GroupProvider? groupProvider; // Provider cho dữ liệu nhóm (có thể null)
  final bool? isAdmin; // Biến cờ để xác định người dùng hiện tại có phải là quản trị viên hay không (có thể null)
  final UserModel? userModel; // Thông tin người dùng cho mô hình người dùng (có thể null)

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại từ Provider
    final currentUser = context.read<AuthenticationProvider>().userModel!;

    // Xác định hình ảnh hồ sơ dựa trên userModel hoặc groupProvider
    final profileImage = userModel != null
        ? userModel!.image // Sử dụng ảnh đại diện của người dùng nếu có
        : groupProvider!.groupModel.groupImage; // Nếu không, sử dụng ảnh đại diện của nhóm

    // Xác định tên hồ sơ dựa trên userModel hoặc groupProvider
    final profileName = userModel != null
        ? userModel!.name // Sử dụng tên của người dùng nếu có
        : groupProvider!.groupModel.groupName; // Nếu không, sử dụng tên của nhóm

    // Xác định phần giới thiệu cá nhân hoặc mô tả nhóm dựa trên userModel hoặc groupProvider
    final aboutMe = userModel != null
        ? userModel!.aboutMe // Sử dụng phần giới thiệu cá nhân của người dùng nếu có
        : groupProvider!.groupModel.groupDescription; // Nếu không, sử dụng mô tả của nhóm

    return Card(
      elevation: 2, // Độ nâng của thẻ
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng để hiển thị ảnh đại diện và tên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userImageWidget(
                    imageUrl: profileImage, radius: 50, onTap: () {}), // Widget hiển thị ảnh đại diện
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      profileName, // Hiển thị tên hồ sơ
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Hiển thị số điện thoại nếu là người dùng hiện tại
                    userModel != null && currentUser.uid == userModel!.uid
                        ? Text(
                      currentUser.phoneNumber, // Số điện thoại của người dùng hiện tại
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        : const SizedBox.shrink(), // Nếu không, không hiển thị gì

                    const SizedBox(height: 5),
                    userModel != null
                        ? ProfileStatusWidget(
                      userModel: userModel!, // Widget hiển thị trạng thái hồ sơ cho người dùng
                      currentUser: currentUser,
                    )
                        : GroupStatusWidget(
                      isAdmin: isAdmin!, // Widget hiển thị trạng thái nhóm cho quản trị viên
                      groupProvider: groupProvider!,
                    ),

                    const SizedBox(height: 10),
                  ],
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
            ),
            Text(userModel != null ? 'Về Tôi' : 'Mô Tả Nhóm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            Text(
              aboutMe, // Hiển thị phần giới thiệu cá nhân hoặc mô tả nhóm
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
