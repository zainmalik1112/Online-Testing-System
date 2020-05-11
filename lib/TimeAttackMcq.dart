import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:fun/TimeAttackResult.dart';
import 'MCQ.dart';

class TimeAttackMcq extends StatefulWidget {

  final List<MCQ> timeAttack;
  final subject;
  final test;
  TimeAttackMcq({this.subject,this.test,this.timeAttack});
  @override
  _TimeAttackMcqState createState() => _TimeAttackMcqState(
    subject: this.subject,
    test: this.test,
    timeAttack: this.timeAttack,
  );
}

class _TimeAttackMcqState extends State<TimeAttackMcq> {

  final List<MCQ> timeAttack;
  final subject;
  final test;
  List<String> selectedOptions = [];
  int questionNumber = 0;
  Color opAColor = AppColors.containerColor();
  Color opBColor = AppColors.containerColor();
  Color opCColor = AppColors.containerColor();
  Color opDColor = AppColors.containerColor();
  final player = AudioCache();
  String status = "";
  Color statusColor = AppColors.containerColor();
  _TimeAttackMcqState({this.test,this.subject,this.timeAttack});
  Timer timer;
  Timer t;
  bool cancel;
  int seconds;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(test == 'ECAT')
      seconds = 60;
    else if(test == 'NET')
      seconds = 75;
    else
      seconds = 65;

    for(int i = 0; i < timeAttack.length; i++){
      selectedOptions.add(null);
    }
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

        if(questionNumber == timeAttack.length - 1){
          t.cancel();
          calculateResult();
          return;
        }

        setState(() {
          status = '';
          statusColor = AppColors.backgroundColor();
          if(questionNumber == timeAttack.length - 1){
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

  calculateResult()
  {
    int attempted = 0;

    for(int i = 0; i < selectedOptions.length; i++){
      if(selectedOptions[i] != null)
        attempted++;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeAttackResult(attempted: attempted, totalQuestions: timeAttack.length)
      )
    );
  }

  Future<bool> _willPopCallback() async {
    quit();
    // await showDialog or Show add banners or whatever
    // then
    return false;// return true if the route to be popped
  }

  quit()
  {
    showDialog(
        context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(
            'Quit Time Attack?',
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
          content: Text(
              'Are you sure you want to quit time attack?'
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 18.0
                ),
              ),
              onPressed: (){
                setState(() {
                  cancel = true;
                });
                Navigator.of(context).pop();
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),

            FlatButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18.0,
                ),
              ),
              onPressed: ()=> Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                quit();
              });
            },
          ),
          backgroundColor: Colors.pink,
          title: Text(
            subject+'-Time Attack',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: "Times New Roman",
            ),
          ),
        ),
        body: status.isEmpty ? buildBody() : buildAnswerBody(),
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

              Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: AppColors.containerColor(),
                ),
                child: Center(
                  child: Text(
                    timeAttack[questionNumber].statement,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
              ),

              buildOptionContainer(timeAttack[questionNumber].opA, opAColor, 'A'),
              buildOptionContainer(timeAttack[questionNumber].opB, opBColor, 'B'),
              buildOptionContainer(timeAttack[questionNumber].opC, opCColor, 'C'),
              buildOptionContainer(timeAttack[questionNumber].opD, opDColor, 'D'),

              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    (questionNumber+1).toString()+"/30",
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
              if(text == timeAttack[questionNumber].correctAnswer){
                selectedOptions[questionNumber] = text;
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
                selectedOptions[questionNumber] = text;
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

            if(questionNumber == timeAttack.length - 1){
              calculateResult();
              return;
            }

            setState(() {
              if(test == 'ECAT')
                seconds = 60;
              else if(test == 'NET')
                seconds = 75;
              else
                seconds = 65;
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
