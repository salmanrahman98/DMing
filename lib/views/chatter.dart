import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_bird/helperfunctions/sharedprefrence.dart';
import 'package:go_bird/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatterPage extends StatefulWidget {
  final String rName, rUsername;

  ChatterPage(this.rName, this.rUsername);

  @override
  _ChatterPageState createState() => _ChatterPageState();
}

class _ChatterPageState extends State<ChatterPage> {
  String chatRoomId, messageId = "";
  String senderName, senderProfilePic, senderUserName, senderEmail;
  TextEditingController messageBoxController = TextEditingController();
  Stream messageStream;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    onLaunchRun();
    super.initState();
  }

  onLaunchRun() async {
    await getInfoFromSharedPref();
    getAndSetMessages();
  }

  addMessage(bool sendClicked) {
    if (messageBoxController.text.isNotEmpty) {
      String message = messageBoxController.text;
      var lastMessageTimeStamp = DateTime.now();

      Map<String, dynamic> thatMessageInfo = {
        "message": message,
        "timeStamp": lastMessageTimeStamp,
        "sentBy": senderUserName,
        "imgUrl": senderProfilePic,
      };

      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, thatMessageInfo)
          .then((value) {
        Map<String, dynamic> lastMessageInfoMap = {
          "lasMessageSentBy": senderUserName,
          "lastMessageTimeStamp": lastMessageTimeStamp,
          "lastMessageText": message,
        };

        DatabaseMethods().updateLastMessageSent(chatRoomId, lastMessageInfoMap);
      });
    }

    if (sendClicked) {
      messageBoxController.clear(); // clearing the text if send btn clicked
      messageId = ""; //clearing message id for new message
    }
  }

  Widget chatMessages() {
    return StreamBuilder(
        stream: messageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(bottom: 70, top: 10),
                  itemCount: snapshot.data.docs.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data.docs[index];
                    return chatMessageTile(documentSnapshot["message"],
                        documentSnapshot["sentBy"] == senderUserName);
                  })
              : Center(child: CircularProgressIndicator());
        });
  }

  Widget chatMessageTile(String message, bool sentByMe) {
    return Row(
      mainAxisAlignment:
          sentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          // width: MediaQuery.of(context).size.width * 0.7,
          // width: 300,
          constraints: BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
              color: sentByMe ? Colors.red : Colors.blue,
              // border: BorderRadius.circular(29),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft:
                      sentByMe ? Radius.circular(20) : Radius.circular(5),
                  bottomRight:
                      sentByMe ? Radius.circular(5) : Radius.circular(20))),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          padding: EdgeInsets.all(10),
          child: Text(
            message,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }

  getAndSetMessages() async {
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {});
  }

  getInfoFromSharedPref() async {
    senderName = await SharedPref().getDisplayName();
    senderProfilePic = await SharedPref().getProfilePic();
    senderUserName = await SharedPref().getUserName();
    senderEmail = await SharedPref().getUserEmail();

    chatRoomId = getChatroomId(senderUserName, widget.rUsername);
  }

  getChatroomId(String n1, n2) {
    int x = n2.compareTo(n1);
    if (x > 0) {
      return "$n1\_$n2";
    } else {
      return "$n2\_$n1";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(widget.rName),
      ),
      body: Container(
        child: Stack(
          children: [
            chatMessages(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black12,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        margin: EdgeInsets.only(left: 20),
                        child: TextField(
                          onChanged: (v) {
                            if (messageBoxController.text.length > 1) {
                              _scrollController.animateTo(0.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut);
                              addMessage(false);
                            }
                          },
                          controller: messageBoxController,
                          decoration: InputDecoration(
                              hintText: "Type your message . . .",
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(right: 5),
                          child: Icon(Icons.send_rounded)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
