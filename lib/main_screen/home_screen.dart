import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/main_screen/groups_screen.dart';
import 'package:chatapp_firebase/main_screen/my_chats_screen.dart';
import 'package:chatapp_firebase/main_screen/people_screen.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  final List<Widget> pages = [
    MyChatsScreen(),
    GroupsScreen(),
    PeopleScreen()
  ];

  @override
  Widget build(BuildContext context) {
    //TODO: truyen anh vao  man hinh home
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(" App Chat Demo"),
        actions:  [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: userImageWidget(
                imageUrl: authProvider.userModel!.image,
                radius: 20,
                onTap: () {
                  //TODO:navigate to profile user  with uis as argument
                  Navigator.pushNamed(context,Constants.profileScreen,arguments: authProvider.userModel!.uid);
                }),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.rocketchat), label: 'Chat'),
          // BottomNavigationItem
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.fortyTwoGroup), label: 'Nhóm'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.peopleRobbery), label: 'Mọi người'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          // animate to the page
          pageController.animateToPage(index,
              duration: const Duration(microseconds: 300),
              curve: Curves.easeIn);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
