import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/CommentScreen.dart';
import 'package:fun/Post.dart';
import 'package:timeago/timeago.dart' as TimeAgo;
import 'package:fun/AppColors.dart';


class DiscussionPanel extends StatefulWidget {

  final currentUserID;
  DiscussionPanel({this.currentUserID});

  @override
  _DiscussionPanelState createState() => _DiscussionPanelState(currentUserID: this.currentUserID);
}

class _DiscussionPanelState extends State<DiscussionPanel> {

  final currentUserID;
  _DiscussionPanelState({this.currentUserID});

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildDiscussionPanel();
  }

  Scaffold buildDiscussionPanel() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Post(currentUserID: currentUserID),
            ),
          );
        },
      ),
      backgroundColor: AppColors.backgroundColor(),
      body: buildDiscussionBody(),
    );
  }

  buildDiscussionBody() {
    return SafeArea(
        child: ListView(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 10.0, right: 8.0, top: 8.0,bottom: 5.0),
                child: Text(
                    'News Feed',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 23.0,
                    )
                )
            ),

            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('NewsFeed')
                  .orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData)
                  return SpinKitHourGlass(
                    color: Colors.blueAccent,
                    size: 30,
                  );

                final newsFeed = snapshot.data.documents;
                List<Widget> posts = [];

                for(var feed in newsFeed){
                  final statement = feed.data['statement'];
                  final username = feed.data['username'];
                  final email = feed.data['email'];
                  final photoUrl = feed.data['photoUrl'];
                  final id = feed.data['postID'];
                  final userID = feed.data['userID'];
                  final time = feed.data['timestamp'];
                  posts.add(buildQuestionContainer(username,email,photoUrl,statement,id,userID,time));
                }

                return Column(
                  children: posts,
                );
              },
            )
          ],
        )
    );
  }

  buildQuestionContainer(String username,String email,String photoUrl,String statement,String id,String uid,Timestamp time) {

    String postID = id;
    String userID = uid;

    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: AppColors.containerColor(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              userID == currentUserID ? Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: ListTile(
                  leading: photoUrl.isEmpty ? CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      username.substring(0,1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                      :CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.deepOrange,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  title: Text(
                      username,
                      style: TextStyle(
                        fontSize: 25,
                        color: AppColors.textColor(),
                      )
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: AppColors.textColor(),
                      size: 25,
                    ),
                    onPressed: (){
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return AlertDialog(
                              title: Text(
                                'Delete Post',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                              content: Text('Are you sure you want to delete the post?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: (){
                                    Firestore.instance.collection('NewsFeed').document(postID).delete();
                                    Firestore.instance.collection('Comments').document(postID).delete();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                      'No',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18,
                                      )
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          }
                      );
                    },
                  ),
                ),
              ):Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: ListTile(
                  leading: photoUrl.isEmpty ? CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      username.substring(0,1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 35.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                      :CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.deepOrange,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  title: Text(
                      username,
                      style: TextStyle(
                        fontSize: 25,
                        color: AppColors.textColor(),
                      )
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                  child: Text(
                    statement,
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 20.0,
                    ),
                  )
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 20.0,bottom: 8.0,top: 2.0),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppColors.textColor(),
                            size: 20,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 2.0, bottom: 8.0),
                            child: Text(TimeAgo.format(time.toDate()),
                                style: TextStyle(
                                  color: AppColors.textColor(),
                                )
                            )
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 25.0, top: 2.0, bottom: 8.0),
                              child: Icon(
                                Icons.comment,
                                size: 20,
                                color: AppColors.textColor(),
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 8.0, top: 2.0, bottom: 8.0),
                              child: Text('comments',
                                  style: TextStyle(
                                    color: AppColors.textColor(),
                                  )
                              )
                          ),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentScreen(
                              postID: postID,
                              currentUserID: currentUserID,
                              username: username,
                              email: email,
                              photoUrl: photoUrl,
                              statement: statement,
                              uid: userID,
                              time: time,
                              notification: false,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          )
      ),
    );
  }
}

