import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';

import '../models/message_model.dart';
import 'align_message_left_widget.dart';
import 'align_message_right_widget.dart';

class SwipeToWidget extends StatelessWidget {
  const SwipeToWidget({
    super.key,
    required this.onRightSwipe,
    required this.message,
    required this.isMe,
    required this.isGroupChat,
  });

  final Function() onRightSwipe;
  final MessageModel message;
  final bool isMe;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    return SwipeTo(
        onRightSwipe: (details) {
          onRightSwipe();
        },
        child: isMe
            ? AlignMessageRightWidget(
                message: message,
                isGroupChat: isGroupChat,
              )
            : AlignMessageLeftWidget(
                message: message,
                isGroupChat: isGroupChat,
              ));
  }
}
