import'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/User.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

class Post extends StatefulWidget {

  final currentUserID;
  Post({this.currentUserID});

  @override
  _PostState createState() => _PostState(currentUserID: this.currentUserID);
}

class _PostState extends State<Post> {

  var uuid = Uuid();
  final currentUserID;
  final fireStore = Firestore.instance;
  User user;
  bool showIndicator = false;
  _PostState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'New Question',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Times New Roman",
          )
        )
      ),
      body: ModalProgressHUD(
        inAsyncCall: showIndicator,
        child: FutureBuilder(
          future: fireStore.collection('UserData').document(currentUserID).get(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(!snapshot.hasData)
              return Center(child: SpinKitHourGlass(
                color: Colors.blue,
                size: 50.0,
              ));
            user = User.fromDoc(snapshot.data);
            return buildQuestionContainer();
          },
        ),
      )
    );
  }

  buildQuestionContainer()
  {
    String username = user.username;
    String email = user.email;
    String statement;
    String photoUrl = user.photoUrl;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Container(
                color: AppColors.containerColor(),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10.0,bottom: 15.0),
                      child: ListTile(
                          leading: photoUrl.isEmpty ? CircleAvatar(
                              backgroundColor: Colors.deepOrange,
                              radius: 30.0,
                              child: Text(
                                  username.substring(0,1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 30.0,
                                  )
                              )
                          ): CircleAvatar(
                            backgroundColor: Colors.deepOrange,
                            radius: 30.0,
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                          title: Text(
                            username,
                            style: TextStyle(
                              color: AppColors.textColor(),
                              fontSize: 24.0,
                            )
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 20, bottom: 10),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.grey[400],
                        ),
                        maxLength: 500,
                        maxLengthEnforced: true,
                        decoration: InputDecoration(
                          labelText: 'Question',
                          labelStyle: TextStyle(
                            fontSize: 20.0,
                            color: Colors.grey,
                          ),
                          contentPadding: EdgeInsets.all(8.0),
                        ),
                        onChanged: (value){
                          statement = value;
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: OutlineButton(
                            borderSide: BorderSide.none,
                            child: Text(
                              'POST',
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 23.0,
                              )
                            ),
                            onPressed: () async {
                              if(statement == null || statement.isEmpty){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      title: Text(
                                          'Fill Question!',
                                        style: TextStyle(
                                          color: Colors.blue,
                                        )
                                      ),
                                      content: Text('Please fill in the question field'),
                                    );
                                  }
                                );
                                return;
                              }

                              setState(() {
                                showIndicator = true;
                              });

                              final id = uuid.v4();

                              await fireStore.collection('NewsFeed').document(id).setData({
                                 'username': username,
                                 'email': email,
                                 'statement': statement,
                                 'photoUrl': photoUrl,
                                 'postID': id,
                                 'userID': currentUserID,
                                 'timestamp': DateTime.now(),
                               });

                              setState(() {
                                showIndicator = false;
                              });

                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                )
            )
          ],
        )
      )
    );
  }
}