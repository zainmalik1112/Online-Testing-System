import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ChallengedIntroductionScreen.dart';
import 'package:fun/NewChallenge.dart';
import 'package:fun/User.dart';
import 'package:fun/ViewChallenge.dart';
import 'package:timeago/timeago.dart' as TimeAgo;

class Challenge extends StatefulWidget {

  final String currentUserID;
  Challenge({this.currentUserID});

  @override
  _ChallengeState createState() => _ChallengeState(
    currentUserID: this.currentUserID,
  );
}

class _ChallengeState extends State<Challenge> {

  final String currentUserID;
  _ChallengeState({this.currentUserID});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(
          Icons.add,
          size: 30.0,
          color: Colors.white,
        ),
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewChallenge(currentUserID: currentUserID),
            )
          );
        },
      ),
      body: buildBody(),
    );
  }

  buildResultContainer(String result)
  {
    Color containerColor;
    if(result == "YOU WON")
      containerColor = Colors.green;
    else if(result == "DRAW"){
      containerColor = Colors.grey;
    }
    else if(result == "YOU LOST")
      containerColor = Colors.red;

    return Container(
      color: containerColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        result,
        style: TextStyle(
          color: AppColors.textColor(),
          fontSize: 15.0,
        ),
      ),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Challenge History:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('Challenges').document(currentUserID)
                    .collection('Challenges').orderBy('timestamp',descending: true).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(!snapshot.hasData){
                return SpinKitHourGlass(
                  color: Colors.blueAccent,
                  size: 30.0,
                );
              }

              List<Widget> list = [];
              final challenges = snapshot.data.documents;

              for(var history in challenges){
                final challengedID = history.data['challengedID'];
                final challengedScore = history.data['challengedScore'];
                final challengerID = history.data['challengerID'];
                final challengerScore = history.data['challengerScore'];
                final notification = history.data['notification'];
                final roomID = history.data['roomID'];
                final status = history.data['status'];
                final Timestamp timestamp = history.data['timestamp'];
                final winnerID = history.data['winnerID'];
                final subject = history.data['subject'];

                if(status == 'pending' && currentUserID == challengerID){
                  list.add(
                    buildChallengerPending(challengedID, challengedScore, challengerID,
                        challengerScore, notification, roomID, status, timestamp, winnerID,subject)
                  );
                }
                else if(status == 'pending' && currentUserID == challengedID){
                  list.add(
                    buildChallengedPending(challengedID, challengedScore, challengerID,
                        challengerScore, notification, roomID, status, timestamp, winnerID,subject)
                  );
                }
                else if(status == 'completed' && currentUserID == challengerID){
                  list.add(
                    buildChallengerCompleted(challengedID, challengedScore,
                        challengerID, challengerScore, notification,
                        roomID, status, timestamp, winnerID, subject)
                  );
                }
                else if(status == 'completed' && currentUserID == challengedID){
                  list.add(
                    buildChallengedCompleted(challengedID, challengedScore, challengerID, challengerScore,
                        notification, roomID, status, timestamp, winnerID, subject)
                  );
                }
              }

              return Container(
                color: AppColors.containerColor(),
                child: Column(
                  children: list,
                ),
              );
            },
          )
        ],
      ),
    );
  }

  buildChallengerPending(String challengedID, int challengedScore, String challengerID, int challengerScore
      ,String notification,String roomID, String status, Timestamp timestamp, String winnerID,String subject)
  {
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(challengedID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SpinKitRipple(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        User user = User.fromDoc(snapshot.data);

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0),
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
                  'You challenged '+user.username+' in $subject',
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      TimeAgo.format(timestamp.toDate()),
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 15.0,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(6.0),
                      padding: EdgeInsets.all(4.0),
                      color: Colors.blueAccent,
                      child: Text(
                        status,
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        );
      },
    );
  }

  buildChallengedPending(String challengedID, int challengedScore, String challengerID, int challengerScore
      ,String notification,String roomID, String status, Timestamp timestamp, String winnerID, String subject)
  {
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(challengerID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SpinKitRipple(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        User user = User.fromDoc(snapshot.data);

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0),
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
                  user.username + ' Challenged You in $subject',
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      TimeAgo.format(timestamp.toDate()),
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 15.0,
                      ),
                    ),
                    notification != 'new' ? Text('') : Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(2.0),
                      color: Colors.red,
                      child: Text(
                        notification,
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.red,
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 15.0,
                    ),
                  ),
                ),
                onTap: (){
                  if(notification == 'new'){
                    Firestore.instance.collection('Challenges').document(challengedID)
                        .collection('Challenges').document(roomID).updateData({
                      'notification':'old',
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChallengedIntroductionScreen(
                        challengedID: challengedID,
                        challengerID: challengerID,
                        challengerScore: challengerScore,
                        subject: subject,
                        roomID: roomID,
                      )
                    )
                  );
                },
              ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        );
      },
    );
  }

  buildChallengerCompleted(String challengedID, int challengedScore, String challengerID, int challengerScore
      ,String notification,String roomID, String status, Timestamp timestamp, String winnerID,String subject)
  {
    String result;
    if(winnerID == challengerID){
      result = "YOU WON";
    }
    else if(winnerID == "draw"){
      result = "DRAW";
    }
    else{
      result = "YOU LOST";
    }
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(challengedID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SpinKitRipple(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        User user = User.fromDoc(snapshot.data);

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0),
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
                  user.username,
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      TimeAgo.format(timestamp.toDate()),
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 15.0,
                      ),
                    ),
                    notification != 'new' ? Text(''):Container(
                      margin: EdgeInsets.all(6.0),
                      padding: EdgeInsets.all(4.0),
                      color: Colors.red,
                      child: Text(
                        notification,
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  ],
                ),
                trailing: buildResultContainer(result),
                onTap: (){
                  if(notification == 'new'){
                    Firestore.instance.collection('Challenges').document(challengerID)
                        .collection('Challenges').document(roomID).updateData({
                      'notification':'old',
                    });
                  }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewChallenge(
                            challengedID: challengedID,
                            challengerID: challengerID,
                            currentUserID: currentUserID,
                            challengerScore: challengerScore,
                            challengedScore: challengedScore,
                            subject: subject,
                            winnerID: winnerID,
                            roomID: roomID,
                          )
                      )
                  );
                },
              ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        );
      },
    );
  }

  buildChallengedCompleted(String challengedID, int challengedScore, String challengerID, int challengerScore
      ,String notification,String roomID, String status, Timestamp timestamp, String winnerID,String subject)
  {
    String result;
    if(winnerID == challengedID){
      result = "YOU WON";
    }
    else if(winnerID == "draw"){
      result = "DRAW";
    }
    else{
      result = "YOU LOST";
    }
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(challengerID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(!snapshot.hasData){
          return SpinKitRipple(
            color: Colors.blueAccent,
            size: 30.0,
          );
        }

        User user = User.fromDoc(snapshot.data);

        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 8.0),
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
                  user.username,
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      TimeAgo.format(timestamp.toDate()),
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 15.0,
                      ),
                    ),
                    notification != 'new' ? Text(''):Container(
                      margin: EdgeInsets.all(6.0),
                      padding: EdgeInsets.all(4.0),
                      color: Colors.red,
                      child: Text(
                        notification,
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 15.0,
                        ),
                      ),
                    )
                  ],
                ),
                trailing: buildResultContainer(result),
                onTap: (){
                  if(notification == 'new'){
                    Firestore.instance.collection('Challenges').document(challengedID)
                        .collection('Challenges').document(roomID).updateData({
                      'notification':'old',
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewChallenge(
                        challengedID: challengedID,
                        challengerID: challengerID,
                        currentUserID: currentUserID,
                        challengerScore: challengerScore,
                        challengedScore: challengedScore,
                        subject: subject,
                        winnerID: winnerID,
                        roomID: roomID,
                      )
                    )
                  );
                },
              ),
            ),
            Divider(
              color: Colors.grey,
            )
          ],
        );
      },
    );
  }
}
