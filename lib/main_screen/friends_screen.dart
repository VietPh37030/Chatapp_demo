import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/widgets/friends_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/app_bar_back-button.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
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


            const Expanded(child: FriendsList(viewType: FriendViewType.friends,))
          ],
        ),
      ),
    );
  }
}
