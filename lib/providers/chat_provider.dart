import 'package:chatapp_firebase/constants.dart';
import 'package:chatapp_firebase/models/last_message_model.dart';
import 'package:chatapp_firebase/models/message_model.dart';
import 'package:chatapp_firebase/models/message_reply_model.dart';
import 'package:chatapp_firebase/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;

  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  // fire initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //send  text message to firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      var messageId = const Uuid().v4();
      //1:check if the message reply and  add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      MessageEnum repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;
      //print(repliedMessage);
      //2:Update/set the messagemodel
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
      );

      //TODO:3:check if its  a group message and send the group else  send to contact
      if (groupId.isNotEmpty) {
//handle group message
      } else {
//hand contact message
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );
        //TODO:set message reply model to null
        setMessageReplyModel(null);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> handleContactMessage(
      {required MessageModel messageModel,
      required String contactUID,
      required String contactName,
      required String contactImage,
      required Function onSuccess,
      required Function(String p1) onError}) async {
    try {
      //TODO:0:contact messageModel
      final contactMessageModel =
          messageModel.copyWith(userId: messageModel.senderUID);
//TODO:1: initialize last message for the sender
      final senderLastMessage = LastMessageModel(
          senderUID: messageModel.senderUID,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          message: messageModel.message,
          messageType: messageModel.messageType,
          timeSent: messageModel.timeSent,
          isSeen: false);
      //TODO:2: initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.contactUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      //TODO:3: send message to sender firestore location
      await _firestore
          .collection('users')
          .doc(messageModel.senderUID)
          .collection('chats')
          .doc(contactUID)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());

//TODO:run transaction
      await _firestore.runTransaction((transaction) async {
//TODO:3: send message to sender firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId),
          messageModel.toMap(),
        );
        //TODO:4: send message to contact firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID)
              .collection(Constants.messages)
              .doc(messageModel.messageId),
          contactMessageModel.toMap(),
        );
        //TODO:5: send  the last message to sender  firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(messageModel.senderUID)
              .collection(Constants.chats)
              .doc(contactUID),
          senderLastMessage.toMap(),
        );
        //TODO:6: send  the last message to contact  firestore location
        transaction.set(
          _firestore
              .collection(Constants.users)
              .doc(contactUID)
              .collection(Constants.chats)
              .doc(messageModel.senderUID),
          contactLastMessage.toMap(),
        );
      });
      //TODO:7:call onSuccess
      onSuccess();
    } on FirebaseException catch (e) {
      onError(e.message ?? e.toString());
    } catch (e) {
      onError(e.toString());
    }
  }

  //TODO:get chatlist stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LastMessageModel.fromMap(doc.data());
      }).toList();
    });
  }

//TODO:Stream message from  chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
    required String isGroup,
  }) {
    //TODO:1:check  if it  aa group message
    if(isGroup.isNotEmpty){
      //handle  group message
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }else{
        //handle  contact message
      return _firestore
         .collection(Constants.users)
         .doc(userId)
         .collection(Constants.chats)
         .doc(contactUID)
         .collection(Constants.messages)
         .orderBy(Constants.timeSent, descending: false)
         .snapshots()
         .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MessageModel.fromMap(doc.data());
        }).toList();
      });
    }
  }
}
