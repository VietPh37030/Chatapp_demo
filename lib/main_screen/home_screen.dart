import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatapp_firebase/main_screen/chats_list_screen.dart';
import 'package:chatapp_firebase/main_screen/groups_list_screen.dart';
import 'package:chatapp_firebase/main_screen/people_screen.dart';
import 'package:chatapp_firebase/utilities/assets_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController  = PageController(initialPage: 0);
  int currentIndex = 0;
  final List<Widget> pages = [
    ChatsListScreen(),
   GroupsListScreen(),
   PeopleScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(" App Chat Demo"),
        actions: const [
         Padding(
           padding: EdgeInsets.all(8.0),
           child: CircleAvatar(
             backgroundColor: Colors.white,
             radius: 20,
             backgroundImage: AssetImage(AssetsManager.userImage),
           ),
         )
        ],
      ),

      body: PageView(
        controller: pageController,
        onPageChanged: (index){
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:  const[
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_2),label: 'Chats'),// BottomNavigationItem
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.group),label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.globe),label: 'People'),

        ],
        currentIndex: currentIndex,
        onTap: (index){
          // animate to the page
          pageController.animateToPage(index, duration: const Duration(microseconds: 300), curve: Curves.easeIn);
         setState(() {
           currentIndex = index;
         });
        },

      ),
    );
  }
}