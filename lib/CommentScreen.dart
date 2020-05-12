import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:uuid/uuid.dart';
import 'package:fun/User.dart';
import 'package:timeago/timeago.dart' as TimeAgo;

class CommentScreen extends StatefulWidget {
  
  final String postID;
  final String currentUserID;
  final String username;
  final String email;
  final String photoUrl;
  final String statement;
  final String uid;
  final Timestamp time;
  final bool notification;

  CommentScreen({this.postID,this.currentUserID,
    this.username,this.email,this.photoUrl,this.statement,this.uid,this.time,this.notification});
  
  @override
  _CommentScreenState createState() => _CommentScreenState(
      postID: this.postID ,
      currentUserID: this.currentUserID,
      username: this.username,
      email: this.email,
      photoUrl: this.photoUrl,
      statement: this.statement,
      uid: this.uid,
      time: this.time,
      notification: this.notification
  );
}

class _CommentScreenState extends State<CommentScreen> {

   String comment;
   final String postID;
   final String currentUserID;
   final String username;
   final String email;
   final String photoUrl;
   final String statement;
   final String uid;
   final Timestamp time;
   final bool notification;
   TextEditingController controller;
   var uuid;
   
   _CommentScreenState({this.postID,this.currentUserID,this.username,
     this.email,this.photoUrl,this.statement,this.uid,this.time,this.notification});

   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  sendNotification() async
  {
    var notificationID = Uuid().v4();
    await Firestore.instance.collection('Notifications').document(uid).collection('Notifications')
        .document(notificationID).setData({
      'notificationID': notificationID,
      'commentatorID': currentUserID,
      'postID': postID,
      'username': username,
      'email': email,
      'photoUrl': photoUrl,
      'statement': statement,
      'uid': uid,
      'timestamp': time,
      'commentTimestamp': DateTime.now(),
      'status': 'new',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Times New Roman",
          )
        )
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Container(
            child: ListView(
              children: <Widget>[
                notification == false ?
                buildQuestionContainer(username, email, photoUrl, statement, postID, uid, time):
                buildQuestionContainerFromNotification(username, email, photoUrl, statement, postID, uid, time),
                 buildComments(),
              ],
            ),
          )),
          Divider(
            color: Colors.grey,
          ),
          Container(
            child: ListTile(
              title: TextFormField(
                controller: controller,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 20.0,
                ),
                decoration: InputDecoration(
                  labelText: "Write a comment....",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  )
                ),
                onChanged: (value){
                  comment = value;
                },
              ),
              trailing: OutlineButton(
                borderSide: BorderSide.none,
                child: Text(
                  'POST',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 20.0,
                  ),
                ),

                onPressed: () async{

                  if(comment == null || comment.isEmpty){
                    showDialog(context: context,
                      builder: (BuildContext context){
                      return AlertDialog(
                        title: Text(
                            'Alert!',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        content: Text('Please write a comment!'),
                      );
                      }
                    );
                    return;
                  }

                  controller.clear();
                  uuid = Uuid().v4();
                  await Firestore.instance.collection('Comments')
                      .document(postID).collection('Comments').document(uuid).setData({
                    'comment': comment,
                    'userID' : currentUserID,
                    'commentID': uuid,
                    'timestamp': DateTime.now(),
                  });

                  comment = "";

                  if(uid != currentUserID)
                    sendNotification();
                },
              ),
            ),
          )
        ],
      )
    );
  }

  buildComments()
  {
    return StreamBuilder(
      stream: Firestore.instance.collection('Comments').document(postID)
      .collection('Comments').orderBy('timestamp',descending: false).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return SpinKitHourGlass(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        var comments = snapshot.data.documents;
        List<Widget> answers = [];

        for(var comment in comments){
          final theComment = comment.data['comment'];
          final userID = comment.data['userID'];
          final commentID = comment.data['commentID'];
          final timestamp = comment.data['timestamp'];

          answers.add(buildCommentContainer(theComment,userID,commentID,timestamp));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 8.0, bottom: 2.0),
              child: Text(
                answers.length.toString() + ' COMMENTS:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
            Column(
              children: answers,
            )
          ],
        );
      },
    );
  }

  buildCommentContainer(String theComment, String userID, String commentID, Timestamp timestamp){
     String username;
     String photoUrl;

     return FutureBuilder(
       future: Firestore.instance.collection('UserData').document(userID).get(),
       builder: (BuildContext context, AsyncSnapshot snapshot){
         if(!snapshot.hasData){
           return SpinKitRipple(
             color: Colors.blueAccent,
             size: 30,
           );
         }

         User user = User.fromDoc(snapshot.data);
         username = user.username;
         photoUrl = user.photoUrl;

         return Padding(
           padding: const EdgeInsets.only(top: 8.0, left: 2.0, right: 4.0),
           child: Column(
             children: <Widget>[
               Container(
                 decoration: BoxDecoration(
                   color: AppColors.containerColor(),
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(15.0),
                     topRight: Radius.circular(15.0),
                   )
                 ),
                 child: uid == currentUserID || userID == currentUserID ? ListTile(
                   leading: photoUrl.isEmpty ? CircleAvatar(
                     backgroundColor: Colors.deepOrange,
                     radius: 30.0,
                     child: Text(
                         user.username.substring(0,1).toUpperCase(),
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 30,
                       )
                     ),
                   ): CircleAvatar(
                     radius: 30.0,
                     backgroundColor: Colors.deepOrange,
                     backgroundImage: NetworkImage(photoUrl),
                   ),

                   title: Text(
                     username,
                     style: TextStyle(
                       color: AppColors.textColor(),
                       fontSize: 20.0,
                     ),
                   ),

                   subtitle: Text(
                     TimeAgo.format(timestamp.toDate()),
                     style: TextStyle(
                       color: Colors.grey[500],
                     ),
                   ),

                    trailing: IconButton(
                     icon: Icon(
                       Icons.delete,
                       color: AppColors.textColor(),
                     ),
                     onPressed: (){
                       showDialog(
                           context: context,
                         builder: (BuildContext context){
                             return AlertDialog(
                               title: Text(
                                 'Delete Comment!',
                                 style: TextStyle(
                                   color: Colors.blueAccent,
                                 )
                               ),

                               content: Text(
                                 'Are you sure you want to delete the comment?'
                               ),

                               actions: <Widget>[
                                 FlatButton(
                                   child: Text(
                                     'Yes',
                                     style: TextStyle(
                                       fontSize: 18,
                                       color: Colors.blue,
                                     ),
                                   ),

                                   onPressed: (){
                                     Firestore.instance.collection('Comments')
                                         .document(postID).collection('Comments')
                                     .document(commentID).delete();
                                     Navigator.of(context).pop();
                                   },
                                 ),

                                 FlatButton(
                                   child: Text(
                                     'No',
                                     style: TextStyle(
                                       fontSize: 18,
                                       color: Colors.red,
                                     ),
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
                   )
                 ):
                 ListTile(
                     leading: photoUrl.isEmpty ? CircleAvatar(
                       backgroundColor: Colors.deepOrange,
                       radius: 30.0,
                       child: Text(
                           user.username.substring(0,1).toUpperCase(),
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 30,
                           )
                       ),
                     ): CircleAvatar(
                       radius: 30.0,
                       backgroundColor: Colors.deepOrange,
                       backgroundImage: NetworkImage(photoUrl),
                     ),

                     title: Text(
                       username,
                       style: TextStyle(
                         color: AppColors.textColor(),
                         fontSize: 20.0,
                       ),
                     ),

                     subtitle: Text(
                       TimeAgo.format(timestamp.toDate()),
                       style: TextStyle(
                         color: AppColors.textColor(),
                       ),
                     ),
                 ),
               ),
               Container(
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: AppColors.containerColor(),
                   borderRadius: BorderRadius.only(
                     bottomLeft: Radius.circular(15.0),
                     bottomRight: Radius.circular(15.0),
                   )
                 ),
                 child: Padding(
                     padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
                     child: Padding(
                       padding: const EdgeInsets.only(left: 10.0),
                       child: Text(
                         theComment,
                         style: TextStyle(
                           color: AppColors.textColor(),
                           fontSize: 20.0,
                         ),
                       ),
                     )
                 ),
               ),
             ],
           ),
         );
       },
     );
  }

   buildQuestionContainer(String username,String email,String photoUrl,String statement,String id,String uid,Timestamp time) {

     return Container(
         decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(0.0),
           color: AppColors.containerColor(),
         ),
         child: Column(
             mainAxisAlignment: MainAxisAlignment.start,
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: <Widget>[
               Padding(
                 padding: EdgeInsets.only(top: 8.0),
                 child: ListTile(
                   leading: photoUrl.isEmpty ? CircleAvatar(
                     radius: 25.0,
                     backgroundColor: Colors.deepOrange,
                     child: Text(
                       username.substring(0, 1).toUpperCase(),
                       style: TextStyle(
                         fontSize: 35.0,
                         color: Colors.white,
                       ),
                     ),
                   )
                       : CircleAvatar(
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
                   padding: EdgeInsets.symmetric(
                       vertical: 10.0, horizontal: 20.0),
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
                             padding: EdgeInsets.only(
                                 left: 20.0, bottom: 8.0, top: 2.0),
                             child: Icon(
                               Icons.calendar_today,
                               color: AppColors.textColor(),
                               size: 20,
                             ),
                           ),
                           Padding(
                               padding: EdgeInsets.only(
                                   left: 8.0, top: 2.0, bottom: 8.0),
                               child: Text(TimeAgo.format(time.toDate()),
                                   style: TextStyle(
                                     color: AppColors.textColor(),
                                   )
                               )
                           ),
                         ],
                       ),
                     ),
                   ]
               )
             ]
         )
     );
   }

   buildQuestionContainerFromNotification(String username,
       String email,String photoUrl,String statement,String id,String uid,Timestamp time) {

     return FutureBuilder(
       future: Firestore.instance.collection('UserData').document(uid).get(),
       builder: (BuildContext context, AsyncSnapshot snapshot){
         if(!snapshot.hasData){
           return SpinKitRipple(
             color: Colors.blueAccent,
             size: 30.0,
           );
         }

         User user = User.fromDoc(snapshot.data);

         return Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(0.0),
               color: AppColors.containerColor(),
             ),
             child: Column(
                 mainAxisAlignment: MainAxisAlignment.start,
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: <Widget>[
                   Padding(
                     padding: EdgeInsets.only(top: 8.0),
                     child: ListTile(
                       leading: photoUrl.isEmpty ? CircleAvatar(
                         radius: 25.0,
                         backgroundColor: Colors.deepOrange,
                         child: Text(
                           user.username.substring(0, 1).toUpperCase(),
                           style: TextStyle(
                             fontSize: 35.0,
                             color: Colors.white,
                           ),
                         ),
                       )
                           : CircleAvatar(
                         radius: 25.0,
                         backgroundColor: Colors.deepOrange,
                         backgroundImage: NetworkImage(user.photoUrl),
                       ),
                       title: Text(
                           user.username,
                           style: TextStyle(
                             fontSize: 25,
                             color: AppColors.textColor(),
                           )
                       ),
                     ),
                   ),
                   Padding(
                       padding: EdgeInsets.symmetric(
                           vertical: 10.0, horizontal: 20.0),
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
                                 padding: EdgeInsets.only(
                                     left: 20.0, bottom: 8.0, top: 2.0),
                                 child: Icon(
                                   Icons.calendar_today,
                                   color: AppColors.textColor(),
                                   size: 20,
                                 ),
                               ),
                               Padding(
                                   padding: EdgeInsets.only(
                                       left: 8.0, top: 2.0, bottom: 8.0),
                                   child: Text(TimeAgo.format(time.toDate()),
                                       style: TextStyle(
                                         color: AppColors.textColor(),
                                       )
                                   )
                               ),
                             ],
                           ),
                         ),
                       ]
                   )
                 ]
             )
         );
       },
     );
   }
}
