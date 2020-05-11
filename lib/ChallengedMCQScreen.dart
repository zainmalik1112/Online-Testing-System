import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'AppColors.dart';
import 'MCQ.dart';

class ChallengedMCQScreen extends StatefulWidget {

  final String challengedID;
  final int challengerScore;
  final String challengerID;
  final String roomID;
  final String subject;
  final List<MCQ> challenge;
  ChallengedMCQScreen({this.subject,this.challengedID,this.challengerID,
    this.challengerScore,this.roomID,this.challenge});

  @override
  _ChallengedMCQScreenState createState() => _ChallengedMCQScreenState(
    challengerScore: this.challengerScore,
    challengedID: this.challengedID,
    challengerID: this.challengerID,
    challenge: this.challenge,
    subject: this.subject,
    roomID: this.roomID,
  );
}

class _ChallengedMCQScreenState extends State<ChallengedMCQScreen> {

  final String challengedID;
  final int challengerScore;
  final String challengerID;
  final String roomID;
  final String subject;
  final List<MCQ> challenge;
  bool loading = false;
  int yourScore = 0;
  int questionNumber = 0;
  Color opAColor = AppColors.containerColor();
  Color opBColor = AppColors.containerColor();
  Color opCColor = AppColors.containerColor();
  Color opDColor = AppColors.containerColor();
  final player = AudioCache();
  String status = "";
  Color statusColor = AppColors.containerColor();
  Timer timer;
  Timer t;
  int seconds;
  bool cancel = false;

  _ChallengedMCQScreenState({this.subject,this.challengerID,this.challengedID,this.roomID
  ,this.challengerScore,this.challenge});

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return false;// return true if the route to be popped
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    seconds = 75;
    startTimer();
  }

  void startTimer() async
  {
    timer = Timer.periodic(Duration(seconds: 1), (t) async {
      if(cancel == true) {
        t.cancel();
        return;
      }

      setState(() {
        seconds--;
      });

      if(seconds == 0) {
        setState(() {
          status = 'Time UP!';
          statusColor = Colors.deepOrange;
        });
        await Future.delayed(Duration(seconds: 1));

        if(questionNumber == challenge.length - 1){
          t.cancel();
          setState(() {
            loading = true;
            cancel = true;
          });
          checkChallengeResult();
          return;
        }

        setState(() {
          status = '';
          statusColor = AppColors.backgroundColor();
          if(questionNumber == challenge.length - 1){
            seconds = 75;
            t.cancel();
          }
          else{
            seconds = 75;
            questionNumber++;
          }
        });
      }
    });
  }

  checkChallengeResult() async
  {
    String winnerID;

    if(yourScore > challengerScore){
      winnerID = challengedID;
    }
    else if(yourScore < challengerScore){
      winnerID = challengerID;
    }
    else if(yourScore == challengerScore){
      winnerID = 'draw';
    }

    await Firestore.instance.collection('Challenges').document(challengedID)
          .collection('Challenges').document(roomID).updateData({
      'challengedScore': yourScore,
      'notification': 'new',
      'status': 'completed',
      'winnerID': winnerID,
      'timestamp': DateTime.now(),
    });

    await Firestore.instance.collection('Challenges').document(challengerID)
        .collection('Challenges').document(roomID).updateData({
      'challengedScore': yourScore,
      'notification': 'new',
      'status': 'completed',
      'winnerID': winnerID,
      'timestamp': DateTime.now(),
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.pink,
          title: Text(
            subject+'-Challenge',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: "Times New Roman",
            ),
          ),
        ),
        body: status.isEmpty ? ModalProgressHUD(
          inAsyncCall: loading,
          child: buildBody(),
        ) : ModalProgressHUD(
          inAsyncCall: loading,
          child: buildAnswerBody(),
        ),
      ),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60.0),
                    color: AppColors.containerColor(),
                  ),
                  padding: EdgeInsets.all(15.0),
                  margin: EdgeInsets.all(10.0),
                  child: Text(
                    '$seconds',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 35.0,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Your Score: $yourScore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),

              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: AppColors.containerColor(),
                ),
                child: Center(
                  child: Text(
                    challenge[questionNumber].statement,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),

              buildOptionContainer(challenge[questionNumber].opA, opAColor, 'A'),
              buildOptionContainer(challenge[questionNumber].opB, opBColor, 'B'),
              buildOptionContainer(challenge[questionNumber].opC, opCColor, 'C'),
              buildOptionContainer(challenge[questionNumber].opD, opDColor, 'D'),

              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  (questionNumber+1).toString()+"/"+(challenge.length.toString()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.0,
                  ),
                ),
              ),
            ],
          )
        ],
      ) ,
    );
  }

  buildOptionContainer(String text, Color color, String op)
  {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 15.0),
      child: GestureDetector(
        child: Container(
          height: 45.0,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: color,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 22.0,
              ),
            ),
          ),
        ),
        onTap: () async{
          setState(() {
            if(text == challenge[questionNumber].correctAnswer){
              yourScore++;
              status = "Correct!";
              statusColor = Colors.green;
              player.play('note1.wav');
              if(op == 'A')
                opAColor = Colors.green;
              else if(op == 'B')
                opBColor = Colors.green;
              else if(op == 'C')
                opCColor = Colors.green;
              else if(op == 'D')
                opDColor = Colors.green;
            }
            else {
              status = "Wrong!";
              statusColor = Colors.red;
              player.play('wrong.mp3');
              if (op == 'A')
                opAColor = Colors.red;
              else if (op == 'B')
                opBColor = Colors.red;
              else if (op == 'C')
                opCColor = Colors.red;
              else if (op == 'D')
                opDColor = Colors.red;
            }
          });

          await Future.delayed(Duration(milliseconds: 700));

          if(questionNumber == challenge.length - 1){
            setState(() {
              cancel = true;
              loading = true;
            });
            checkChallengeResult();
            return;
          }

          setState(() {
            seconds = 75;
            opAColor = AppColors.containerColor();
            opBColor = AppColors.containerColor();
            opCColor = AppColors.containerColor();
            opDColor = AppColors.containerColor();
            status = "";
            statusColor = AppColors.backgroundColor();
            questionNumber++;
          });
        },
      ),
    );
  }

  buildAnswerBody()
  {
    return Center(
        child:  ScaleAnimatedTextKit(
          text: [
            status,
          ],

          textStyle: TextStyle(
            fontSize: 70,
            fontWeight: FontWeight.w700,
            color: statusColor,
          ),
          textAlign: TextAlign.start,
          alignment: AlignmentDirectional.topStart,
          duration: Duration(milliseconds: 700),
          isRepeatingAnimation: false,
        )
    );
  }
}