import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/last_message_model.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/providers/chat_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
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

            Expanded(
              child: StreamBuilder<List<LastMessageModel>>(
                stream: context.read<ChatProvider>().getChatsListStream(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Có lỗi xảy ra'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    final chatsList = snapshot.data!;
                    return ListView.builder(
                        itemCount: chatsList.length,
                        itemBuilder: (context, index) {
                          final chat = chatsList[index];
                          //TODO:set thời gian theo thư viện
                          final dateTime = formatDate(chat.timeSent, [hh,':',nn,'',am]);
                          //TODO:check if we  send  the last message
                          final isMe = chat.senderUID == uid;
                          //TODO: dis the last  message correct
                          final lastMessage =
                              isMe ? 'Bạn : ${chat.message}' : chat.message;
                          return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(chat.contactImage),
                              ),
                              title: Text(chat.contactName),
                              subtitle: Text(
                               lastMessage,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(dateTime),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, Constants.chatScreen,
                                    arguments: {
                                      Constants.contactUID: chat.contactUID,
                                      Constants.contactName: chat.contactName,
                                      Constants.contactImage: chat.contactImage,
                                      Constants.groupId: '',
                                    });
                              });
                        });
                  }
                  return const Center(
                    child: Text('No chat yet'),
                  );
                },
              ),
//TODO:Stream the lastMessage
            )
          ],
        ),
      ),
    );
  }
}
