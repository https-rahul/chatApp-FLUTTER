import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversationScreen.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

String _myName;

class _SearchScreenState extends State<SearchScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextController = new TextEditingController();
  QuerySnapshot searchSnapshot;

  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
        itemCount: searchSnapshot.documents.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return SearchTile(
              userName: searchSnapshot.documents[index].data["name"],
              userEmail: searchSnapshot.documents[index].data["email"]);
        })
        : Container();
  }

  initiateSearch() {
    databaseMethods.getUserByUsername(searchTextController.text).then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  //TODO: create chatroom, send user to convo screen, pushreplacement

  createChatroomAndSendStartConversation({String userName}) {
    print("${Constants.myName} goddamitt");
    if(userName != Constants.myName){
      String chatRoomId = getChatRoomId(userName, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };

      DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ConversationScreen(chatRoomId)));
    } else {
      print("u cant search yourself");
    }
  }

  Widget SearchTile({final String userName,
    String userEmail}) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  userName,
                  style: simpleTextStyle(),
                ),
                Text(
                  userEmail,
                  style: simpleTextStyle(),
                )
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                createChatroomAndSendStartConversation(userName : userName);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Message",
                  style: simpleTextStyle(),
                ),
              ),
            ),
          ],
        ));
  }

  @override
  void initState() {
    initiateSearch();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            color: Color(0x54FFFFFF),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      controller: searchTextController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText: "search by user...",
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none),
                    )),
                GestureDetector(
                  onTap: () {
                    initiateSearch();
                  },
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        //TODO: add color only when something has entered!
                          color: Color(0xff145c9e),
                          borderRadius: BorderRadius.circular(40)),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
          searchList()
        ],
      ),
    );
  }
}


getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
