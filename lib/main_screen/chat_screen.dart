import 'package:chatapp_firebase/models/message_model.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/providers/chat_provider.dart';
import 'package:chatapp_firebase/widgets/bottom_chat_field.dart';
import 'package:chatapp_firebase/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // current user id
    final uid = context.read<AuthenticationProvider>().userModel!.uid;

    //TODO:get  arguments passed from previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //TODO:Get the contantUID from the arguments
    final contactUID = arguments[Constants.contactUID];
    final contactName = arguments[Constants.contactName];
    final contactImage = arguments[Constants.contactImage];
    final groupId = arguments[Constants.groupId];
//TODO:Check if  the groupID is Empty - then its  a chat with a friend else it is a group chat
    final isGroupChat = groupId.isNotEmpty ? true : false;
    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessagesStream(
                    userId: uid, contactUID: contactUID, isGroup: groupId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    final messagesList = snapshot.data!;
                    return ListView.builder(
                        itemCount: messagesList.length,
                        itemBuilder: (context, index) {
                          final message = messagesList[index];
                          final dateTime = formatDate(
                              message.timeSent, [hh, ':', nn, '',am]);
                          // check if we sent  the last  message
                          final isMe = message.senderUID == uid;
                          return Card(
                            color: isMe
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor,
                            child: ListTile(
                              title: Text(
                                message.message,
                                style: TextStyle(
                                  color: isMe
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                dateTime,
                                style: TextStyle(
                                  color: isMe
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        });
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            //chat mess list
            BottomChatField(
                contactUID: contactUID,
                contactName: contactName,
                contactImage: contactImage,
                groupId: groupId)
          ],
        ),
      ),
    );
  }
}
