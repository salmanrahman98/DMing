import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_bird/helperfunctions/sharedprefrence.dart';

class DatabaseMethods {
  Future addUserInfotoFirestore(
      String userID, Map<String, dynamic> userInfo) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(userID)
        .set(userInfo);
  }

  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("username", isEqualTo: username)
        .snapshots();
  }

  Future addMessage(
      String chatRoomId, String messageId, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  Future updateLastMessageSent(String chatRoomId, Map lastMessageInfo) async {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomId)
        .update(lastMessageInfo);
  }

  Future addChatRoom(String chatRoomId, Map chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("ChatRooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatroomList() async {
    String myUserName = await SharedPref().getUserName();
    return FirebaseFirestore.instance
        .collection("ChatRooms")
        .orderBy("lastMessageTimeStamp", descending: true)
        .where("Users", arrayContains: myUserName)
        .snapshots();
  }
}
