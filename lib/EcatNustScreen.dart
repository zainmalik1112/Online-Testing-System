import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CustomizedSubject.dart';
import 'package:fun/MCQ.dart';
import 'package:fun/PerformanceScreen.dart';
import 'package:fun/QuestionNumbers.dart';
import 'package:uuid/uuid.dart';

class EcatNustScreen extends StatefulWidget {

  final String test;
  final String field;
  final List<MCQ> fullTest;
  final List<CustomizedSubject> subjects;
  final currentUserID;
  final int customizedMinutes;
  final int customizedSeconds;
  EcatNustScreen({this.test, this.field, this.fullTest,this.subjects,this.currentUserID,
  this.customizedMinutes,this.customizedSeconds});

  @override
  _EcatNustScreenState createState() => _EcatNustScreenState(
    test: this.test,
    field: this.field,
    fullTest: this.fullTest,
    subjects: this.subjects,
    currentUserID: this.currentUserID,
    customizedMinutes: this.customizedMinutes,
    customizedSeconds: this.customizedSeconds,
  );
}

class _EcatNustScreenState extends State<EcatNustScreen> {

  final String test;
  final String field;
  final currentUserID;
  final int customizedMinutes;
  final int customizedSeconds;
  final List<MCQ> fullTest;
  final List<CustomizedSubject> subjects;
  List<String> selectedOptions = [];
  int questionNumber = 0;
  int attempted = 0;
  int unAttempted = 0;
  int totalScore;
  int correct = 0;
  int incorrect = 0;
  int testScore = 0;
  int minutes;
  int seconds;
  Timer timer;
  Timer t;
  bool cancel = false;

  _EcatNustScreenState({this.test, this.field, this.fullTest,this.subjects,this.currentUserID,
  this.customizedMinutes,this.customizedSeconds});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for(int i = 0 ; i < fullTest.length; i++)
      selectedOptions.add(null);
    if(test == 'ECAT'){
      minutes = 100;
      seconds = 0;
    }
    else if(test == 'NET'){
      minutes = 180;
      seconds = 0;
    }
    else if(test == 'FAST-NU'){
      minutes = 100;
      seconds = 0;
    }
    else if(test == 'NTS'){
      minutes = 90;
      seconds = 0;
    }
    else{
      minutes = customizedMinutes;
      seconds = customizedSeconds;
    }
    startTimer();
  }

  void previousQuestion()
  {
    setState(() {
      if (questionNumber != 0) {
        questionNumber = questionNumber - 1;
      }
    });
  }

  void loadNextQuestion()
  {
    setState(() {
      if (questionNumber != fullTest.length - 1)
        questionNumber = questionNumber + 1;
    });
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
        if(test == 'ECAT'){
          calculateECATScore();
        }
        else if(test == 'FAST-NU'){
          calculateFASTScore();
        }
        else if(test == 'NET'){
          calculateNUSTScore();
        }
        else{
          calculateCustomizedTestScore();
        }
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
    var testID = Uuid().v4();

    await Firestore.instance.collection('FullTestPerformance')
        .document(currentUserID).collection('TestRecord')
        .document(testID).setData({
      'userID': currentUserID,
      'testID': testID,
      'attempted': attempted,
      'unattempted': unAttempted,
      'correct': correct,
      'incorrect': incorrect,
      'testScore': testScore,
      'totalScore': totalScore,
      'test': test,
      'timestamp': DateTime.now(),
    });

   for(int i = 0; i < fullTest.length; i++){

     await Firestore.instance.collection('FullTestCollection')
         .document(testID).collection('Questions').document(fullTest[i].id)
         .setData({
       'id': fullTest[i].id,
       'test': fullTest[i].test,
       'subject': fullTest[i].subject,
       'chapter': fullTest[i].chapter,
       'statement': fullTest[i].statement,
       'opA': fullTest[i].opA,
       'opB': fullTest[i].opB,
       'opC': fullTest[i].opC,
       'opD': fullTest[i].opD,
       'correctAnswer': fullTest[i].correctAnswer,
       'explanation': fullTest[i].explanation,
       'difficulty': fullTest[i].difficulty,
     });
   }
  }

  calculateECATScore()
  {
    totalScore = 400;
    for(int i = 0; i < fullTest.length; i++){
      if(selectedOptions[i] == fullTest[i].correctAnswer){
        attempted++;
        correct++;
        testScore = testScore + 4;
      }
      else if(selectedOptions[i] != fullTest[i].correctAnswer && selectedOptions[i] != null){
        incorrect++;
        attempted++;
        testScore = testScore - 1;
      }
      else if(selectedOptions[i] == null){
        unAttempted++;
      }
    }

    savePerformance();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerformanceScreen(
          attempted: attempted.toDouble(),
          unattempted: unAttempted.toDouble(),
          incorrect: incorrect.toDouble(),
          correct: correct.toDouble(),
          totalQuestions: fullTest.length.toDouble(),
          testScore: testScore.toDouble(),
          totalMarks: totalScore.toDouble(),
          testType: 'FullFledge',
          questions: fullTest,
          selectedOptions: selectedOptions,
        )
      )
    );
  }

  calculateNUSTScore()
  {
    totalScore = 200;
    for(int i = 0; i < fullTest.length; i++){
      if(selectedOptions[i] == fullTest[i].correctAnswer){
        attempted++;
        correct++;
        testScore = testScore + 1;
      }
      else if(selectedOptions[i] != fullTest[i].correctAnswer && selectedOptions[i] != null){
        incorrect++;
        attempted++;
      }
      else if(selectedOptions[i] == null){
        unAttempted++;
      }
    }

    savePerformance();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PerformanceScreen(
              attempted: attempted.toDouble(),
              unattempted: unAttempted.toDouble(),
              incorrect: incorrect.toDouble(),
              correct: correct.toDouble(),
              totalQuestions: fullTest.length.toDouble(),
              testScore: testScore.toDouble(),
              totalMarks: totalScore.toDouble(),
              testType: 'FullFledge',
              questions: fullTest,
              selectedOptions: selectedOptions,
            )
        )
    );
  }

  calculateCustomizedTestScore()
  {
     totalScore = fullTest.length;
     for(int i = 0; i < fullTest.length; i++){
       if(selectedOptions[i] == fullTest[i].correctAnswer){
         attempted++;
         correct++;
         testScore = testScore + 1;
       }
       else if(selectedOptions[i] != fullTest[i].correctAnswer && selectedOptions[i] != null){
         incorrect++;
         attempted++;
       }
       else if(selectedOptions[i] == null){
         unAttempted++;
       }
     }

     Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) => PerformanceScreen(
               attempted: attempted.toDouble(),
               unattempted: unAttempted.toDouble(),
               incorrect: incorrect.toDouble(),
               correct: correct.toDouble(),
               totalQuestions: fullTest.length.toDouble(),
               testScore: testScore.toDouble(),
               totalMarks: totalScore.toDouble(),
               testType: 'FullFledge',
               questions: fullTest,
               selectedOptions: selectedOptions,
             )
         )
     );
  }

  calculateFASTScore()
  {
    totalScore = 100;
    for(int i = 0; i < fullTest.length; i++){
      if(selectedOptions[i] == fullTest[i].correctAnswer){
        attempted++;
        correct++;
        testScore++;
      }
      else if(selectedOptions[i] != fullTest[i].correctAnswer && selectedOptions[i] != null){
        incorrect++;
        attempted++;
      }
      else if(selectedOptions[i] == null){
        unAttempted++;
      }
    }

    savePerformance();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PerformanceScreen(
              attempted: attempted.toDouble(),
              unattempted: unAttempted.toDouble(),
              incorrect: incorrect.toDouble(),
              correct: correct.toDouble(),
              totalQuestions: fullTest.length.toDouble(),
              testScore: testScore.toDouble(),
              totalMarks: totalScore.toDouble(),
              testType: 'FullFledge',
              questions: fullTest,
              selectedOptions: selectedOptions,
            )
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
    showDialog(context: context,
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
                  setState(() {
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

  calculateResult()
  {
    setState(() {
      cancel = true;
    });

    if(test == 'ECAT')
      calculateECATScore();
    else if(test == 'NET')
      calculateNUSTScore();
    else if(test == 'FAST-NU')
      calculateFASTScore();
    else
      calculateCustomizedTestScore();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(
            '$test-'+fullTest[questionNumber].subject,
            style: TextStyle(
              fontSize: test == 'Customized Test' ? 22 : 25,
              fontFamily: "Times New Roman",
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.cancel,
              size: 35.0,
              color: Colors.white,
            ),
            onPressed: (){
              quit();
            }
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 2.0),
              child: IconButton(
                icon: Icon(
                  Icons.assignment_turned_in,
                  size: 35.0,
                  color: Colors.white,
                ),
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        title: Text(
                          'Submit Test?',
                          style: TextStyle(
                            color: Colors.blueAccent,
                          ),
                        ),
                        content: Text(
                            'Are you sure you want to submit the test? Your progress will be saved if'
                                ' the test is not customized.'
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
        backgroundColor: AppColors.backgroundColor(),
        body: buildBody(),
      ),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Container(
              padding: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
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
                        padding: EdgeInsets.all(8.0),
                        margin: EdgeInsets.only(left: 80.0, right: 80.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: AppColors.backgroundColor(),
                        ),
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
                          fullTest[questionNumber].statement,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                          )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '($test, '+ fullTest[questionNumber].difficulty+')',
                          style: TextStyle(
                              color: Colors.white,
                            fontSize: 18.0,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          buildOptionContainer(fullTest[questionNumber].opA,fullTest[questionNumber].correctAnswer),
          buildOptionContainer(fullTest[questionNumber].opB,fullTest[questionNumber].correctAnswer),
          buildOptionContainer(fullTest[questionNumber].opC,fullTest[questionNumber].correctAnswer),
          buildOptionContainer(fullTest[questionNumber].opD,fullTest[questionNumber].correctAnswer),

          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                (questionNumber+1).toString()+'/'+fullTest.length.toString(),
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 18.0,
                ),
              ),
            ),
          ),

          Padding(
              padding: EdgeInsets.all(10),
              child: buildMCQNavigator(),
          ),

          Padding(
            padding: EdgeInsets.only(left: 18.0, top: 5.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Go To question-->',
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),

                GestureDetector(
                  child: Icon(
                    Icons.arrow_drop_up,
                    color: AppColors.textColor(),
                    size: 40.0,
                  ),

                  onTap: () async{
                    int number = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuestionNumbers(
                            length: fullTest.length,
                          selectedOptions: selectedOptions,
                          currentIndex: questionNumber,
                        ),
                      )
                    );

                    if(number == null)
                      return;

                    setState(() {
                      questionNumber = number - 1;
                    });
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(left: 18.0, top: 5.0),
            child: Row(
              children: <Widget>[
                Text(
                  'Go To Subject-->',
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),

                GestureDetector(
                  child: Icon(
                    Icons.arrow_drop_up,
                    color: AppColors.textColor(),
                    size: 40.0,
                  ),

                  onTap: () {
                    showBottomSheet();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
                previousQuestion();
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
              if (questionNumber != fullTest.length - 1)
                loadNextQuestion();
            });
          },
        ),
      ],
    );
  }

  setIndex(String theSubject)
  {
    for(int i = 0; i < fullTest.length; i++){
      if(fullTest[i].subject == theSubject) {
        setState(() {
          questionNumber = i;
        });
        break;
      }
    }
  }

  showBottomSheet()
  {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            color: AppColors.backgroundColor(),
            child: ListView(
              children: getBottomSheetElements(),
            ),
          );
        }
    );
  }

  List<Widget> getBottomSheetElements()
  {
    List<Widget> list = [];

    list.add(
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
          child: Text(
              'Choose Subject to jump on:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        ),
      )
    );

    if(test == 'ECAT'){
      list.add(addElement('Physics', 'images/physics.png'));
      list.add(addElement('Mathematics', 'images/maths.png'));
      list.add(addElement('English', 'images/english.png'));
      if(field == 'Pre-Engineering')
        list.add(addElement('Chemistry', 'images/chemistry.png'));
      else
        list.add(addElement('Computer Science', 'images/computerScience.png'));
    }
    else if(test == 'NET'){
      list.add(addElement('Mathematics', 'images/maths.png'));
      list.add(addElement('Physics', 'images/physics.png'));
      if(field == 'Pre-Engineering')
        list.add(addElement('Chemistry', 'images/chemistry.png'));
      else
        list.add(addElement('Computer Science', 'images/computerScience.png'));
      list.add(addElement('English', 'images/english.png'));
      list.add(addElement('Intelligence', 'images/IQ.png'));
    }
    else if(test == 'NTS'){
      list.add(addElement('Mathematics', 'images/maths.png'));
      list.add(addElement('Physics', 'images/physics.png'));
      if(field == 'Pre-Engineering')
        list.add(addElement('Chemistry', 'images/chemistry.png'));
      else
        list.add(addElement('Computer Science', 'images/computerScience.png'));
      list.add(addElement('English', 'images/english.png'));
      list.add(addElement('Intelligence', 'images/IQ.png'));
    }
    else if(test == 'FAST-NU'){
      list.add(addElement('Basic Mathematics', 'images/basicMaths.png'));
      list.add(addElement('Mathematics', 'images/maths.png'));

      if(field == 'Pre-Engineering')
        list.add(addElement('Physics', 'images/physics.png'));

      list.add(addElement('English', 'images/english.png'));
      list.add(addElement('Intelligence', 'images/IQ.png'));
    }
    else if(test == 'Customized Test'){
      for(int i = 0; i < subjects.length; i++){
        if(subjects[i].subject == 'Chemistry'){
          list.add(addElement('Chemistry', 'images/chemistry.png'));
        }
        else if(subjects[i].subject == 'Physics'){
          list.add(addElement('Physics', 'images/physics.png'));
        }
        else if(subjects[i].subject == 'Mathematics'){
          list.add(addElement('Mathematics', 'images/maths.png'));
        }
        else if(subjects[i].subject == 'Computer Science'){
          list.add(addElement('Computer Science', 'images/computerScience.png'));
        }
        else if(subjects[i].subject == 'English'){
          list.add(addElement('English', 'images/english.png'));
        }
      }
    }

    return list;
  }

  addElement(String text, String image)
  {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: AppColors.containerColor(),
        ),
        padding: EdgeInsets.all(5.0),
        child: ListTile(
          leading: Image(
            image: AssetImage(image),
          ),
          title: Text(
           text,
           style: TextStyle(
             color: AppColors.textColor(),
             fontSize: 20.0,
           ),
          ),
          onTap: (){
            Navigator.of(context).pop();
            setIndex(text);
          },
        ),
      ),
    );
  }


  buildOptionContainer(String text,String correct) {
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
                text == correct ? '$text (correct)' : text,
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
