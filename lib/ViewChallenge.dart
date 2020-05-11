import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/ViewChallengeQuestions.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'AppColors.dart';
import 'User.dart';
import 'MCQ.dart';

class ViewChallenge extends StatefulWidget {

  final String currentUserID;
  final String challengerID;
  final String challengedID;
  final String winnerID;
  final int challengerScore;
  final int challengedScore;
  final String subject;
  final String roomID;

  ViewChallenge({this.roomID,this.subject,this.currentUserID,this.challengerID,this.challengedID,this.winnerID,
  this.challengerScore,this.challengedScore});

  @override
  _ViewChallengeState createState() => _ViewChallengeState(
    currentUserID: this.currentUserID,
    challengerID: this.challengerID,
    challengedID: this.challengedID,
    winnerID: this.winnerID,
    challengerScore: this.challengerScore,
    challengedScore: this.challengedScore,
    subject: this.subject,
    roomID: this.roomID,
  );
}

class _ViewChallengeState extends State<ViewChallenge> {

  final String currentUserID;
  final String challengerID;
  final String challengedID;
  final String winnerID;
  final int challengerScore;
  final int challengedScore;
  final String subject;
  final String roomID;
  List<MCQ> challenge = [];
  bool progress = false;

  _ViewChallengeState({this.roomID,this.subject,this.currentUserID,this.challengerID,this.challengedID,this.winnerID,
    this.challengerScore,this.challengedScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          '$subject-Challenge',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Times New Roman",
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: progress,
        child: buildBody(),
      )
    );
  }

  buildBody()
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: showResult(),
        ),
        buildDetails(),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: OutlineButton(
            borderSide: BorderSide.none,
            child: Text(
              'VIEW QUESTIONS',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 25.0,
              ),
            ),
            onPressed: () async{
              setState(() {
                progress = true;
              });

              try{
               await getQuestions();
              }
              catch(e){
                showAlertDialogue(e.toString());
                setState(() {
                  progress = false;
                });
                return;
              }

              setState(() {
                progress = false;
              });

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewChallengeQuestions(questions: challenge)
                )
              );

              challenge.clear();
            },
          ),
        )
      ],
    );
  }

  showResult()
  {
    String result;
    Color containerColor;
    if(winnerID == currentUserID){
      result = "YOU WON";
      containerColor = Colors.green;
    }
    else if(winnerID == 'draw'){
      result = "DRAW";
      containerColor = Colors.grey;
    }
    else{
      result = "YOU LOST";
      containerColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: containerColor,
      ),
      child: Text(
        result,
        style: TextStyle(
          color: AppColors.textColor(),
          fontSize: 40.0,
        ),
      ),
    );
  }

  buildDetails()
  {
    if(currentUserID == challengedID){
      return showDetails(challengedID, challengedScore.toString(), challengerID, challengerScore.toString());
    }
    else if(currentUserID == challengerID){
      return showDetails(challengerID, challengerScore.toString(), challengedID, challengedScore.toString());
    }
  }

  showAlertDialogue(String message)
  {
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(
              'An Error Occurred!',
              style: TextStyle(
                fontSize: 40.0,
                color: Colors.blueAccent,
              ),
            ),
            content: Text(message),
          );
        }
    );
  }

  showDetails(String firstID, String firstIDScore, String secondID, String secondIDScore)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        buildUserDetail(firstID),
        SizedBox(
          width: 20,
        ),
        Text(
          '$firstIDScore : $secondIDScore',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 30.0,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        buildUserDetail(secondID)
      ],
    );
  }

  buildUserDetail(String id)
  {
    return FutureBuilder(
      future: Firestore.instance.collection('UserData').document(id).get(),
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
            user.photoUrl.isEmpty ? CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.deepOrange,
              child: Text(
                user.username.substring(0,1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50.0,
                ),
              ),
            ): CircleAvatar(
              radius: 50.0,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: 100,
                child: Center(
                  child: Text(
                    user.username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  getQuestions() async
  {
    await Firestore.instance.collection('ChallengeRoom').document(roomID).collection('Questions')
        .getDocuments().then((QuerySnapshot snapshot){
      print(snapshot.documents.length);
      for(int index = 0; index < snapshot.documents.length; index++){
        challenge.add(
            MCQ(
              id: snapshot.documents[index].data['mcqID'],
              statement: snapshot.documents[index].data['statement'],
              opA: snapshot.documents[index].data['opA'],
              opB: snapshot.documents[index].data['opB'],
              opC: snapshot.documents[index].data['opC'],
              opD: snapshot.documents[index].data['opD'],
              correctAnswer: snapshot.documents[index].data['correctAnswer'],
              explanation: snapshot.documents[index].data['explanation'],
              test: snapshot.documents[index].data['test'],
              subject: snapshot.documents[index].data['subject'],
              chapter: snapshot.documents[index].data['chapter'],
              difficulty: snapshot.documents[index].data['difficulty'],
            )
        );
      }
    });
  }
}
