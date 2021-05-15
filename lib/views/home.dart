import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_bird/helperfunctions/sharedprefrence.dart';
import 'package:go_bird/services/auth.dart';
import 'package:go_bird/services/database.dart';
import 'package:go_bird/views/chatter.dart';
import 'package:go_bird/views/signin.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearchMode = false;
  TextEditingController searchTextFiedController = TextEditingController();
  Stream userSearchStream, chatRoomStream;
  String senderName, senderProfilePic, senderUserName, senderEmail;

  onLoader() async {
    await getInfoFromSharedPref();
    getChatRooms();
  }

  @override
  void initState() {
    onLoader();
    super.initState();
  }

  getChatroomId(String n1, n2) {
    int x = n2.compareTo(n1);
    if (x > 0) {
      return "$n1\_$n2";
    } else {
      return "$n2\_$n1";
    }
  }

  getInfoFromSharedPref() async {
    senderName = await SharedPref().getDisplayName();
    senderProfilePic = await SharedPref().getProfilePic();
    senderUserName = await SharedPref().getUserName();
    senderEmail = await SharedPref().getUserEmail();
  }

  onSearchBtnClick() async {
    isSearchMode = true;
    setState(() {});
    userSearchStream = await DatabaseMethods()
        .getUserByUserName(searchTextFiedController.text);
    setState(() {});
  }

  Widget chatRoomsList() {
    return StreamBuilder(
        stream: chatRoomStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    print("nameOf $ds.id");
                    List arr = ds["Users"];
                    arr.remove(senderUserName);
                    return Text(arr[0]);
                  })
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black12,
                  ),
                );
        });
  }

  getChatRooms() async {
    chatRoomStream = await DatabaseMethods().getChatroomList();
    setState(() {});
  }

  Widget searchedUsersLists() {
    return StreamBuilder(
        stream: userSearchStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data.docs[index];
                    return userRow(
                        imgUrl: documentSnapshot["profilePic"],
                        name: documentSnapshot["name"],
                        email: documentSnapshot["email"],
                        username: documentSnapshot["username"]);
                  },
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        });
  }

  Widget userRow({String imgUrl, name, email, username}) {
    return InkWell(
      onTap: () {
        var chatRoomId = getChatroomId(username, senderUserName);

        Map<String, dynamic> chatRoomInfoMap = {
          "Users": [senderUserName, username]
        };

        DatabaseMethods().addChatRoom(chatRoomId, chatRoomInfoMap);

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatterPage(name, username)));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    imgUrl,
                    height: 70,
                    width: 70,
                  )),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                Text(email)
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          InkWell(
            onTap: () {
              AuthenticationMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.logout),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Row(
                  children: [
                    isSearchMode
                        ? GestureDetector(
                            onTap: () {
                              isSearchMode = false;
                              searchTextFiedController.clear();
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Icon(Icons.arrow_back),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: TextField(
                        controller: searchTextFiedController,
                        decoration: InputDecoration(hintText: "User Name"),
                        onChanged: (v) {
                          onSearchBtnClick();
                        },
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          if (searchTextFiedController.text != "") {
                            onSearchBtnClick();
                          }
                        },
                        child: Icon(
                          Icons.search,
                          size: 30,
                        )),
                  ],
                ),
              ),
            ),
            isSearchMode ? searchedUsersLists() : chatRoomsList(),
          ],
        ),
      ),
    );
  }
}
