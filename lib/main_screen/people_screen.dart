import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../enum/enums.dart';
import '../models/user_model.dart';
import '../providers/authentication_provider.dart';
import '../widgets/friend_widget.dart';

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // cupertino search bar
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  placeholder: 'Search',
                ),
              ),

              // list of users
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: context
                      .read<AuthenticationProvider>()
                      .getAllUsersStream(userID: currentUser.uid),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'Không tìm thấy người dùng nào.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2),
                        ),
                      );
                    }

                    return ListView(
                      children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        final data = UserModel.fromMap(
                            document.data()! as Map<String, dynamic>);

                        return FriendWidget(
                            friend: data, viewType: FriendViewType.allUsers);


                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
