import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/User.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'AppColors.dart';

class EditQuestion extends StatefulWidget {

  final currentUserID;
  final postID;
  String statement;

  EditQuestion({this.currentUserID,this.statement,this.postID});

  @override
  _EditQuestionState createState() => _EditQuestionState(
    currentUserID: this.currentUserID,
    postID: this.postID,
    statement: this.statement,
  );
}

class _EditQuestionState extends State<EditQuestion> {

  final currentUserID;
  final postID;
  String statement;
  User user;
  bool showIndicator = false;
  Firestore fireStore = Firestore.instance;
  TextEditingController controller;

  _EditQuestionState({this.postID,this.currentUserID,this.statement});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController(text: statement);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
            backgroundColor: Colors.pink,
            title: Text(
                'Edit Post',
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
                            controller: controller,
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
                                    'SAVE',
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

                                  fireStore.collection('NewsFeed').document(postID).updateData({
                                    'statement': statement,
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
