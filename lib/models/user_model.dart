import 'package:chatapp_firebase/constants.dart';

class UserModel {
  String uid;
  String name;
  String phoneNumber;
  String image;
  String token;
  String aboutMe;
  String lastSeen;
  String createdAt;
  bool isOnline;
  List<String> friendsUIDs;
  List<String> friendsRequestsUIDs;
  List<String> sendRequestsUIDs;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.createdAt,
    required this.isOnline,
    required this.friendsUIDs,
    required this.friendsRequestsUIDs,
    required this.sendRequestsUIDs
  });

//from map
  factory UserModel.fromMap(Map<String, dynamic> map){
    return UserModel(
        uid: map[Constants.uid] ?? '',
        name: map[Constants.name] ?? '',
        phoneNumber: map[Constants.phoneNumber] ?? '',
        image: map[Constants.image] ?? '',
        token: map[Constants.token] ?? '',
        aboutMe: map[Constants.aboutMe] ?? '',
        lastSeen: map[Constants.lastSeen] ?? '',
        createdAt: map[Constants.createdAt] ?? '',
        isOnline: map[Constants.isOnline] ?? '',
        friendsUIDs: List<String>.from(map[Constants.friendsUIDs] ?? []),
        friendsRequestsUIDs: List<String>.from(map[Constants.friendsRequestsUIDs] ?? []),
        sendRequestsUIDs: List<String>.from(map[Constants.sendRequestsUIDs] ?? []),
    );
  }
// to map
  Map<String, dynamic> toMap(){
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
      Constants.friendsUIDs: friendsUIDs,
      Constants.friendsRequestsUIDs: friendsRequestsUIDs,
      Constants.sendRequestsUIDs: sendRequestsUIDs
    };
  }

}