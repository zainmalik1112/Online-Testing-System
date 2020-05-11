import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CommentScreen.dart';
import 'package:fun/User.dart';
import 'package:timeago/timeago.dart' as TimeAgo;

class Notifications extends StatefulWidget {

  final currentUserID;
  Notifications({this.currentUserID});

  @override
  _NotificationsState createState() => _NotificationsState(
    currentUserID: this.currentUserID,
  );
}

class _NotificationsState extends State<Notifications> {

  final currentUserID;
  _NotificationsState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildNotificationPanel();
  }

  buildNotificationPanel() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
            fontFamily: "Times New Roman"
          ),
        ),
      ),
      body: SafeArea(
       child: StreamBuilder(
         stream: Firestore.instance.collection('Notifications').document(currentUserID)
                 .collection('Notifications').orderBy('commentTimestamp', descending: true).snapshots(),
         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
           if(!snapshot.hasData){
             return SpinKitHourGlass(
               color: Colors.blueAccent,
               size: 30.0,
             );
           }

           List<Widget> notifications = [];
           final appNotifications = snapshot.data.documents;

           for(var not in  appNotifications){
             final String notificationID = not.data['notificationID'];
             final String commentatorID = not.data['commentatorID'];
             final String postID = not.data['postID'];
             final String username = not.data['username'];
             final String email = not.data['email'];
             final String photoUrl = not.data['photoUrl'];
             final String statement = not.data['statement'];
             final Timestamp time = not.data['timestamp'];
             final String uid = not.data['uid'];
             final String status = not.data['status'];
             final Timestamp commentTimestamp = not.data['commentTimestamp'];

             notifications.add(
              buildNotification(commentatorID, postID, username, email, photoUrl,
                  statement, time, uid,status,commentTimestamp,notificationID)
             );
           }

           return ListView(
             children: notifications,
           );
         },
       )
      )
    );
  }

  buildNotification(String commentatorID,
      String postID, String username, String email,
      String photoUrl, String statement, Timestamp time, String userID,String status,
      Timestamp commentTimestamp, String notificationID)
  {
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(commentatorID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SpinKitRipple(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        User user = User.fromDoc(snapshot.data);

        return Padding(
          padding: EdgeInsets.only(left: 1.0, right: 1.0, top: 5.0),
          child: Container(
            padding: EdgeInsets.only(bottom: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColors.containerColor(),
            ),
            child: ListTile(
              leading: user.photoUrl.isEmpty ? CircleAvatar(
                backgroundColor: Colors.deepOrange,
                radius: 30.0,
                child: Text(
                  user.username.substring(0,1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                ),
              ): CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 30.0,
              ),
              title: Text(
                user.username + ' commented on your post',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 18.0,
                ),
              ),
              subtitle: status == 'new' ? Row(
                children: <Widget>[
                  Text(
                    TimeAgo.format(commentTimestamp.toDate()),
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    padding: EdgeInsets.all(2.0),
                    color: Colors.red,
                    child: Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  )
                ],
              ): Text(
                TimeAgo.format(commentTimestamp.toDate()),
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 16.0,
                ),
              ),
              onTap: () async{
                if(status == 'new'){
                  await Firestore.instance.collection('Notifications').document(userID).collection('Notifications')
                      .document(notificationID).updateData({
                    'status': 'old',
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentScreen(
                      currentUserID: currentUserID,
                      postID: postID,
                      username: username,
                      email: email,
                      photoUrl: photoUrl,
                      time: time,
                      statement: statement,
                      uid: userID,
                      notification: true,
                    ),
                  )
                );
              },
            ),
          ),
        );
      },
    );
  }
}
