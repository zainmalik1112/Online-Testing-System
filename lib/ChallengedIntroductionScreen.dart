import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ChallengedMCQScreen.dart';
import 'package:fun/MCQ.dart';
import 'package:fun/User.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChallengedIntroductionScreen extends StatefulWidget {

  final String challengedID;
  final int challengerScore;
  final String challengerID;
  final String roomID;
  final String subject;

  ChallengedIntroductionScreen({this.challengedID,this.challengerScore,this.challengerID,this.roomID,this.subject});

  @override
  _ChallengedIntroductionScreenState createState() => _ChallengedIntroductionScreenState(
      challengerID: this.challengerID,
      challengedID: this.challengedID,
      challengerScore: this.challengerScore,
      roomID: this.roomID,
      subject: this.subject,
  );
}

class _ChallengedIntroductionScreenState extends State<ChallengedIntroductionScreen> {

  final String challengedID;
  final int challengerScore;
  final String challengerID;
  final String roomID;
  final String subject;
  bool progress = false;
  List<MCQ> challenge = [];

  _ChallengedIntroductionScreenState({this.subject,this.challengedID,
    this.challengerScore,this.challengerID,this.roomID});

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
              buildUserDetail(challengedID),
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
              buildUserDetail(challengerID)
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
              onPressed: () async{
                   setState(() {
                     progress = true;
                   });

                   try{
                     await prepareChallenge();
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

                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => ChallengedMCQScreen(
                         challengerScore: challengerScore,
                         challengerID: challengerID,
                         challengedID: challengedID,
                         challenge: challenge,
                         subject: subject,
                         roomID: roomID,
                       )
                     )
                   );
              }
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
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
  
  prepareChallenge() async
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