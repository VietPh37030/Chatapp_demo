import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/group_model.dart';
import '../providers/authentication_provider.dart';
import '../providers/group_provider.dart';
import '../utilities/global_methods.dart';
import '../widgets/chat_widget.dart';

class PublicGroupScreen extends StatefulWidget {
  const PublicGroupScreen({super.key});

  @override
  State<PublicGroupScreen> createState() => _PublicGroupScreenState();
}

class _PublicGroupScreenState extends State<PublicGroupScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CupertinoSearchTextField(
            onChanged: (value) {},
          ),
        ),

        // stream builder for private groups
        StreamBuilder<List<GroupModel>>(
          stream:
              context.read<GroupProvider>().getPublicGroupsStream(userId: uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Không có nhóm công khai nào'),
              );
            }
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final groupModel = snapshot.data![index];
                  return ChatWidget(
                      group: groupModel,
                      isGroup: true,
                      onTap: () {
                        // check if user is already a member of the group
                        if (groupModel.membersUIDs.contains(uid)) {
                          context
                              .read<GroupProvider>()
                              .setGroupModel(groupModel: groupModel)
                              .whenComplete(() {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: groupModel.groupId,
                                Constants.contactName: groupModel.groupName,
                                Constants.contactImage: groupModel.groupImage,
                                Constants.groupId: groupModel.groupId,
                              },
                            );
                          });
                          return;
                        }

                        // check if request to join settings is enabled
                        if (groupModel.requestToJoing) {
                          // check if user has already requested to join the group
                          if (groupModel.awaitingApprovalUIDs.contains(uid)) {
                            showSnackBar(context, 'Yêu cầu đã được gửi đi.');
                            return;
                          }

                          // show animation to join group to request to join
                          showMyAnimatedDialog(
                            context: context,
                            title: 'Yêu cầu tham gia.',
                            content:
                                'Bạn cần gửi yêu cầu để tham gia nhóm trước khi bạn có thể xem nội dung của nhóm',
                            textAction: 'Request to join',
                            onActionTap: (value) async {
                              // send request to join group
                              if (value) {
                                await context
                                    .read<GroupProvider>()
                                    .sendRequestToJoinGroup(
                                      groupId: groupModel.groupId,
                                      uid: uid,
                                      groupName: groupModel.groupName,
                                      groupImage: groupModel.groupImage,
                                    )
                                    .whenComplete(() {
                                  showSnackBar(context, 'Yêu cầu đã được gửi đi');
                                });
                              }
                            },
                          );
                          return;
                        }

                        context
                            .read<GroupProvider>()
                            .setGroupModel(groupModel: groupModel)
                            .whenComplete(() {
                          Navigator.pushNamed(
                            context,
                            Constants.chatScreen,
                            arguments: {
                              Constants.contactUID: groupModel.groupId,
                              Constants.contactName: groupModel.groupName,
                              Constants.contactImage: groupModel.groupImage,
                              Constants.groupId: groupModel.groupId,
                            },
                          );
                        });
                      });
                },
              ),
            );
          },
        )
      ],
    ));
  }
}
