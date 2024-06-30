import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enum/enums.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.viewType,
    this.groupId = '',
    this.groupMembersUIDs = const [],
  });

  final FriendViewType viewType;
  final String groupId;
  final List<String> groupMembersUIDs;
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final future = viewType == FriendViewType.friends
        ? context.read<AuthenticationProvider>().getFriendsList(uid)
        : viewType == FriendViewType.friendRequests
            ? context.read<AuthenticationProvider>().getFriendRequestsList(uid)
            : context.read<AuthenticationProvider>().getFriendsList(uid);

    return FutureBuilder<List<UserModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Something went wrong"));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có bạn nào cả"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final data = snapshot.data![index];
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: -10),
                  leading: userImageWidget(
                      imageUrl: data.image,
                      radius: 40,
                      onTap: () {
                        Navigator.pushNamed(context, Constants.profileScreen,
                            arguments: data.uid);
                      }),
                  title: Text(data.name),
                  subtitle: Text(
                    data.aboutMe,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      if (viewType == FriendViewType.friends) {
                        Navigator.pushNamed(context, Constants.chatScreen,
                         arguments: {
                            Constants.contactUID: data.uid,
                            Constants.contactName: data.name,
                            Constants.contactImage: data.image,
                            Constants.groupId: '',
                            });
                      } else if (viewType == FriendViewType.friendRequests) {
                        await context
                            .read<AuthenticationProvider>()
                            .acceptFriendRequest(friendID: data.uid)
                            .whenComplete(() {
                          showSnackBar(
                              context, 'Bạn đã là bạn của ${data.name}');
                        });
                      } else {
//check the check box
                      }
                    },
                    child: viewType == FriendViewType.friends
                        ? const Text('Chat')
                        : const Text('Đồng ý'),
                  ),
                );
              });
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
