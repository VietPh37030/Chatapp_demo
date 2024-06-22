import 'package:chatapp_firebase/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bar_back-button.dart';
import '../widgets/friends_list.dart';
class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: () {
          Navigator.pop(context);
        }),
        centerTitle: true,
        title: Text('Bạn bè'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9.00),
        child: Column(
          children: [
            // Cuputino seacher
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                print(value);
              },
            ),


            const Expanded(child: FriendsList(viewType: FriendViewType.friendRequests,))
          ],
        ),
      ),
    );
  }

}
