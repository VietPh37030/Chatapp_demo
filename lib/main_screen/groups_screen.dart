import 'package:chatapp_firebase/main_screen/private_group_screen.dart';
import 'package:chatapp_firebase/main_screen/public_group_screen.dart';
import 'package:flutter/material.dart';


import 'create_group_screen.dart'; // Import màn hình CreateGroupScreen

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý nhóm'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Cá nhân'),
              Tab(text: 'Cộng đồng'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrivateGroupScreen(),
            PublicGroupScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateGroupScreen(),
              ),
            );
          },
          child: const Icon(Icons.group),
        ),
      ),
    );
  }
}
