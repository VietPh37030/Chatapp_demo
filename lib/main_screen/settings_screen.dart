import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/authentication_provider.dart';
import '../widgets/app_bar_back-button.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  // lấy chế độ giao diện đã lưu
  void getThemeMode() async {
    // lấy chế độ giao diện đã lưu
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    // kiểm tra xem chế độ giao diện đã lưu có phải là giao diện tối không
    if (savedThemeMode == AdaptiveThemeMode.dark) {
      // đặt isDarkMode thành true
      setState(() {
        isDarkMode = true;
      });
    } else {
      // đặt isDarkMode thành false
      setState(() {
        isDarkMode = false;
      });
    }
  }

  @override
  void initState() {
    getThemeMode();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO:logout
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: const Text("Cài đặt"),
        actions: [
          // currentUser.uid == uid?
          IconButton(
            onPressed: () async {
              //Taọ hộp hội thoại khi ta đăng xuat
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text(
                      'Đăng xuất',
                      textAlign: TextAlign.center,
                    ),
                    content: const Text(
                      "Bạn muốn đăng xuất không ?",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            await context
                                .read<AuthenticationProvider>()
                                .logout()
                                .whenComplete(() {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  Constants.loginScreen, (route) => false);
                            });
                          },
                          child: const Text('Đăng Xuất Ngay'))
                    ],
                  ));
            },
            icon: const Icon(Icons.logout),
          )
          // :const SizedBox(),
        ],
      ),
      body: Center(
        child: Card(
          child: SwitchListTile(
            title: const Text("Đổi Giao Diện"),
            secondary: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode? Colors.white :Colors.black,
              ),
              child: Icon(
                isDarkMode ?Icons.nightlight_round : Icons.wb_sunny_rounded,
                color: isDarkMode ?Colors.black:Colors.white,
              ),
            ),
            value: isDarkMode,
            onChanged: (value) {
              // đặt isDarkMode thành giá trị mới
              setState(() {
                isDarkMode = value;
              });
              // kiểm tra nếu giá trị là true
              if (value) {
                // đặt chế độ giao diện thành tối
                AdaptiveTheme.of(context).setDark();
              } else {
                // đặt chế độ giao diện thành sáng
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}
