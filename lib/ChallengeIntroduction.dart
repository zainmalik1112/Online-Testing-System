import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ChallengerMCQScreen.dart';
import 'dart:math' as math;

import 'package:fun/MCQ.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChallengeIntroduction extends StatefulWidget {

  final String currentUserID;
  final String challengedID;
  final String challengedUsername;
  final String challengedPhotoUrl;
  final String currentUserPhotoUrl;
  final String currentUserUsername;
  final String subject;
  ChallengeIntroduction({this.subject,this.currentUserID,this.challengedID,this.challengedUsername
  ,this.challengedPhotoUrl,this.currentUserUsername,this.currentUserPhotoUrl});

  @override
  _ChallengeIntroductionState createState() => _ChallengeIntroductionState(
    currentUserID: this.currentUserID,
    challengedID: this.challengedID,
    challengedUsername: this.challengedUsername,
    challengedPhotoUrl: this.challengedPhotoUrl,
    currentUserPhotoUrl: this.currentUserPhotoUrl,
    currentUserUsername: this.currentUserUsername,
    subject: this.subject,
  );
}

class _ChallengeIntroductionState extends State<ChallengeIntroduction> {

  final String currentUserID;
  final String challengedID;
  final String challengedUsername;
  final String challengedPhotoUrl;
  final String currentUserPhotoUrl;
  final String currentUserUsername;
  final String subject;
  bool progress = false;
  List<String> test;
  List<MCQ> challenge = [];

  _ChallengeIntroductionState({this.subject,this.currentUserID,this.challengedID,this.challengedUsername
    ,this.challengedPhotoUrl,this.currentUserUsername,this.currentUserPhotoUrl});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test = ['ECAT', 'NET', 'FAST-NU'];
  }

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
      body: buildBody(),
    );
  }

  buildBody()
  {
    return ModalProgressHUD(
      inAsyncCall: progress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildUserDetail(currentUserUsername,currentUserPhotoUrl),
              SizedBox(
                width: 20,
              ),
              Text(
                'VS',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              buildUserDetail(challengedUsername, challengedPhotoUrl)
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FlatButton(
              color: Colors.pink,
              child: Text(
                'PROCEED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                ),
              ),
              onPressed: ()async{
                String theTest;
                while(true){
                  theTest = test[math.Random.secure().nextInt(test.length)];
                  if(theTest == 'FAST-NU' && subject == 'Computer Science'){

                  }
                  else if(theTest == 'FAST-NU' && subject == 'Chemistry'){

                  }
                  else
                    break;
                }

                setState(() {
                  progress = true;
                });

                try{
                  await prepareChallenge(theTest);
                }
                catch(e){
                  showAlertDialogue('An error occured!');
                  setState(() {
                    progress = false;
                  });
                  return;
                }

                setState(() {
                  progress = false;
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengerMCQScreen(
                      challengerID: currentUserID,
                      challengedID: challengedID,
                      subject: subject,
                      challenge: challenge,
                    )
                  )
                );
              },
            ),
          )
        ],
      ),
    );
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

  buildUserDetail(String username, String photoUrl)
  {
    return Column(
      children: <Widget>[
        photoUrl.isEmpty ? CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.deepOrange,
          child: Text(
            username.substring(0,1).toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 50.0,
            ),
          ),
        ): CircleAvatar(
          radius: 50.0,
          backgroundImage: NetworkImage(photoUrl),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
        )
      ],
    );
  }

  prepareChallenge(String theTest) async {
    int count = 0;
    await Firestore.instance.collection(theTest)
        .where('test', isEqualTo: theTest)
        .where('subject', isEqualTo: subject)
        .getDocuments().then((QuerySnapshot snapshot){
          print(snapshot.documents.length);
      for(int i = 0; i < snapshot.documents.length; i++){
        int index = math.Random.secure().nextInt(snapshot.documents.length);
        MCQ mcq = MCQ(
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
        );

        if(!challenge.contains(mcq)){
          challenge.add(mcq);
          count++;
        }

        if(count == 6)
          break;
      }
    });
  }
}
