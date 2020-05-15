import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/PerformanceScreen.dart';
import 'package:fun/MCQ.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:uuid/uuid.dart';

class McqScreen extends StatefulWidget {

  final List<MCQ> practiceTest;
  final currentUserID;
  McqScreen({this.practiceTest,this.currentUserID});

  @override
  _McqScreenState createState() => _McqScreenState(
      practiceTest: this.practiceTest,
      currentUserID: this.currentUserID
  );
}

class _McqScreenState extends State<McqScreen> {

  final List<MCQ> practiceTest;
  final currentUserID;
  int questionNumber = 0;
  List<String> selectedOptions = [];
  int attempted = 0;
  int unattempted = 0;
  int correct = 0;
  int incorrect = 0;
  int testScore = 0;
  int minutes = 35;
  int seconds = 00;
  int totalMarks;
  bool showProgress = false;
  Timer timer;
  Timer t;
  bool cancel = false;

  _McqScreenState({this.practiceTest, this.currentUserID});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i = 0; i < practiceTest.length; i++){
      selectedOptions.add(null);
    }
    startTimer();
  }

  void startTimer() async
  {
    timer = Timer.periodic(Duration(seconds: 1), (t){
      if(cancel == true) {
        t.cancel();
        return;
      }

      if(seconds == 0 && minutes!=0) {
        setState(() {
          minutes--;
          seconds = 59;
        });
      }
      else if(minutes == 0 && seconds == 0){
        timer.cancel();
        calculateResult();
        return;
      }
      else{
        setState(() {
          seconds--;
        });
      }
    });

  }

  savePerformance() async
  {
    var uuid = Uuid().v4();

    await Firestore.instance.collection('TestPerformance')
    .document(currentUserID).collection('TestRecord')
    .document(uuid).setData({
      'userID': currentUserID,
      'testID': uuid,
      'attempted': attempted,
      'unattempted': unattempted,
      'correct': correct,
      'incorrect': incorrect,
      'testScore': testScore,
      'totalQuestions': practiceTest.length.toString(),
      'test': practiceTest[0].test,
      'subject': practiceTest[0].subject,
      'chapter': practiceTest[0].chapter,
      'timestamp': DateTime.now(),
    });

    for(int i = 0; i < practiceTest.length; i++){
      await Firestore.instance.collection('TestCollections').document(uuid)
          .collection('Questions').document(practiceTest[i].id).setData({
        'id': practiceTest[i].id,
        'test': practiceTest[i].test,
        'subject': practiceTest[i].subject,
        'chapter': practiceTest[i].chapter,
        'statement': practiceTest[i].statement,
        'opA': practiceTest[i].opA,
        'opB': practiceTest[i].opB,
        'opC': practiceTest[i].opC,
        'opD': practiceTest[i].opD,
        'correctAnswer': practiceTest[i].correctAnswer,
        'explanation': practiceTest[i].explanation,
        'difficulty': practiceTest[i].difficulty,
      });
    }
  }

  void calculateResult()
  {
    totalMarks = practiceTest.length;
    for(int i = 0; i < practiceTest.length; i++){
      if(selectedOptions[i] == practiceTest[i].correctAnswer){
        attempted++;
        correct++;
        testScore++;
      }
      else if(selectedOptions[i] != practiceTest[i].correctAnswer && selectedOptions[i] != null){
        attempted++;
        incorrect++;
      }
      else if(selectedOptions[i] == null){
        unattempted++;
      }
    }

    setState(() {
      showProgress = true;
    });

    savePerformance();

    setState(() {
      showProgress = false;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PerformanceScreen(
            correct: correct.toDouble(),
            incorrect: incorrect.toDouble(),
            attempted: attempted.toDouble(),
            unattempted: unattempted.toDouble(),
            testScore: testScore.toDouble(),
            totalQuestions: practiceTest.length.toDouble(),
            totalMarks: practiceTest.length.toDouble(),
            testType: 'Practice',
            questions: practiceTest,
            selectedOptions: selectedOptions,
          ),
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
              'Quit Test?',
              style: TextStyle(
                color: Colors.blueAccent,
              ),
            ),
            content: Text(
                'Leave the test? Your progress will not be saved.'
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
                  Navigator.of(context).pop();
                  setState((){
                    cancel = true;
                  });
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
          backgroundColor: Colors.pink,
          leading: GestureDetector(
            child: Icon(
              Icons.cancel,
              color: Colors.white,
              size: 35.0,
            ),
            onTap: () {
              quit();
            },
          ),
          title: Text(
            'Practice-TEST',
            style: TextStyle(
              fontFamily: "Times New Roman",
              color: Colors.white,
              fontSize: 25.0,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                child: Icon(
                  Icons.assignment_turned_in,
                  size: 35.0,
                  color: Colors.white,
                ),
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: Text(
                            'Submit Test?',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          content: Text(
                              'Are you sure you want to submit the test? Your progress will be SAVED!.'
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
                                Navigator.of(context).pop();
                                setState(() {
                                  cancel = true;
                                });
                                calculateResult();
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
                },
              ),
            )
          ],
        ),
        body: buildBody(),
      ),
    );
  }


  buildBody() {
    return SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: showProgress,
          child: ListView(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(50.0),
                    ),
                    color: AppColors.containerColor(),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                          child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.timer,
                                      size: 25.0,
                                      color: AppColors.textColor(),
                                    ),
                                  ),
                                  Text(
                                      '$minutes min $seconds sec',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20
                                      )
                                  ),
                                ],
                              )
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Container(
                          child: Text(
                              practiceTest[questionNumber].statement,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              buildOptionContainer(practiceTest[questionNumber].opA),
              buildOptionContainer(practiceTest[questionNumber].opB),
              buildOptionContainer(practiceTest[questionNumber].opC),
              buildOptionContainer(practiceTest[questionNumber].opD),

              Padding(
                  padding: EdgeInsets.all(10),
                  child: buildMCQNavigator(),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40.0,
                  width: double.infinity,
                  child: ListView(

                    scrollDirection: Axis.horizontal,
                    children: getQuestionList(),
                  ),
                ),
              )
            ],
          ),
        )
    );
  }

  buildMCQNavigator(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        GestureDetector(
          child: Icon(
            Icons.arrow_back,
            color: Colors.pink,
            size: 35.0,
          ),
        onTap: () {
          setState(() {
            if (questionNumber != 0) {
              questionNumber = questionNumber - 1;
            }
          });
        },
        ),

        FlatButton(
          child: Text(
            'Unselect option',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          color: Colors.pink,
          onPressed: () {
            setState(() {
              selectedOptions[questionNumber] = null;
            });
          },
        ),

        GestureDetector(
          child: Icon(
            Icons.arrow_forward,
            color: Colors.pink,
            size: 35.0,
          ),
          onTap: () {
            setState(() {
              if (questionNumber != practiceTest.length - 1)
                questionNumber = questionNumber + 1;
            });
          },
        ),
      ],
    );
  }

  List<Widget> getQuestionList()
  {
    List<Widget> list = [];
    for(int i = 0; i < practiceTest.length; i++)
      list.add(buildQuestionNumber(i+1));

    return list;
  }

  buildQuestionNumber(int number)
  {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        child: Container(
          width: 40.0,
          height: 25.0,
          decoration: BoxDecoration(
            borderRadius: questionNumber == number - 1 ? BorderRadius.circular(30.0) : BorderRadius.circular(0),
            color: selectedOptions[number-1] == null ? AppColors.containerColor() : Colors.green,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 20
              ),
            ),
          ),
        ),
        onTap: (){
          setState(() {
            questionNumber = number - 1;
          });
        },
      ),
    );
  }

  buildOptionContainer(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0, bottom: 2.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            color: AppColors.containerColor(),
          ),
          child: ListTile(
            leading: Radio(
              activeColor: Colors.blueAccent,
              value: text,
              groupValue: selectedOptions[questionNumber],
              onChanged: (value) {
                setState(() {
                  selectedOptions[questionNumber] = value;
                  value = selectedOptions[questionNumber];
                });
              },
            ),
            title: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                )
            ),
          )
      ),
    );
  }
}