import 'dart:ui';

import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:chatapp_firebase/utilities/global_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.groupId,
  });

  final String contactUID;
  final String contactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    // Initialize the text editing controller and focus node
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the text editing controller and focus node to free up resources
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Method to send a text message to Firestore
  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    // Sending the text message using chatProvider
    chatProvider.sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupId: widget.groupId,
      onSuccess: () {
        // Clear the text field and request focus after sending the message
        _textEditingController.clear();
        _focusNode.requestFocus();
      },
      onError: (error) {
        // Show an error message if sending fails
       showSnackBar(context, error);

      },
    ); // <-- Added missing semicolon
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: Theme.of(context).primaryColor,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // Show modal bottom sheet for attachments
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: 200,
                    child: const Center(
                      child: Text('Attach to'),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.attachment),
          ),
          Expanded(
            child: TextFormField(
              controller: _textEditingController,
              focusNode: _focusNode,
              decoration: const InputDecoration.collapsed(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Type a message',
              ),
            ),
          ),
          GestureDetector(
            onTap:sendTextMessage,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF2DA5DC),
              ),
              margin: const EdgeInsets.all(5),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
