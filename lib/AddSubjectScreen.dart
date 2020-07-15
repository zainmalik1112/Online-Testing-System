import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CustomizeSubject.dart';
import 'package:fun/CustomizedSubject.dart';
import 'package:fun/EcatNustScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:math' as math;
import 'MCQ.dart';

class AddSubjectScreen extends StatefulWidget {

  final String theTest;
  final String totalLength;
  final int minutes;
  final int seconds;
  AddSubjectScreen({this.totalLength,this.theTest,this.minutes,this.seconds});

  @override
  _AddSubjectScreenState createState() => _AddSubjectScreenState(
    totalLength: this.totalLength,
    theTest: this.theTest,
    minutes: this.minutes,
    seconds: this.seconds,
  );
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {

  int theCurrentLength = 0;
  final String totalLength;
  final String theTest;
  final int minutes;
  final int seconds;
  bool loading = false;
  List<CustomizedSubject> subjects = [];
  List<MCQ> subjectMCQs = [];
  _AddSubjectScreenState({this.totalLength,this.theTest,this.minutes,this.seconds});

  showErrorMessage(String message)
  {
    showDialog(
        context: context,
      builder: (context){
          return AlertDialog(
            title: Text(
              'An Error Occured!',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.blueAccent,
              ),
            ),
            content: Text(message),
          );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Manage Subjects',
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
      inAsyncCall: loading,
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Subjects:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            subjects.length == 5 || theCurrentLength == num.tryParse(totalLength) ?
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.pink,
                    child: MaterialButton(
                      child: Text(
                        'PROCEED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                      onPressed: () async{

                        setState(() {
                          loading = true;
                        });

                        try{
                          await prepareTest();
                        }
                        catch(e){
                          return;
                        }
                          setState(() {
                            loading = false;
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EcatNustScreen(
                                test: theTest,
                                fullTest: subjectMCQs,
                                subjects: subjects,
                                customizedMinutes: minutes,
                                customizedSeconds: seconds,
                              )
                            )
                          );
                      },
                    ),
                  ),
                ):
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(8.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: AppColors.containerColor(),
                ),
                child: Text(
                  'Add Subject+',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20.0,
                  ),
                ),
              ),
              onTap: () async{
                CustomizedSubject subject = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomizeSubject(
                        totalLength: num.tryParse(totalLength),
                        subjects: subjects,
                      ),
                    )
                );

                if(subject == null)
                  return;
                setState(() {
                  subjects.add(subject);
                  theCurrentLength = theCurrentLength + subject.totalQuestions;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Questions added: $theCurrentLength/$totalLength',
                  style: TextStyle(
                    color: theCurrentLength == num.parse(totalLength) ? Colors.lightGreenAccent : Colors.white,
                    fontSize: 15.0,
                  ),
                )
              ],
            ),
            addSubjects(),
          ],
        ),
      ),
    );
  }

  addSubjects()
  {
    return Column(
      children: getSubjects(),
    );
  }

  List<Widget> getSubjects()
  {
    List<Widget> list = [];
    for(int i = 0; i < subjects.length; i++){
      list.add(buildSubjectContainer(
        subjects[i].subject,
        subjects[i].test,
        subjects[i].easyQuestions,
        subjects[i].normalQuestions,
        subjects[i].hardQuestions,
        subjects[i].totalQuestions,
      ));
    }
    return list;
  }

  buildSubjectContainer(String subject, String test, int easy, int normal, int hard, int total)
  {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.containerColor(),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 10.0, bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text(
                subject,
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 25.0,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: AppColors.textColor(),
                  size: 30.0,
                ),
                onPressed: (){
                  for(int i = 0; i < subjects.length; i++){
                    if(subjects[i].subject == subject){
                      setState(() {
                        theCurrentLength = theCurrentLength - subjects[i].totalQuestions;
                        subjects.removeAt(i);
                      });
                    }
                  }
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            subjectDetail('Question Bank', test.toString()),
            subjectDetail('Total Questions', total.toString()),
            subjectDetail('Easy Questions', easy.toString()),
            subjectDetail('Normal Questions', normal.toString()),
            subjectDetail('Hard Questions', hard.toString()),
          ],
        ),
      ),
    );
  }

  subjectDetail(String text, String variable)
  {
    return Text(
      '$text: $variable',
      style: TextStyle(
        color: AppColors.textColor(),
        fontSize: 18.0,
      ),
    );
  }

  prepareTest() async
  {
    try{
      for(int i = 0; i < subjects.length; i++){
        await prepareSubject(
            subjects[i].test,
            subjects[i].subject,
            subjects[i].easyQuestions,
            subjects[i].normalQuestions,
            subjects[i].hardQuestions,
        );
      }
    }
    catch(e){
      showErrorMessage(e.toString());
      return;
    }
  }

  prepareSubject(String bank, String theSubject, int totalEasyCount, int totalNormalCount, int totalHardCount)
  async {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;

    await Firestore.instance.collection(bank)
        .where('test', isEqualTo: bank)
        .where('subject', isEqualTo: theSubject)
        .getDocuments().then((QuerySnapshot snapshot) {
      for (int i = 0; i < snapshot.documents.length; i++) {
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

        if (mcq.difficulty == 'Easy' && easyCount < totalEasyCount) {
          if (!subject.contains(mcq)) {
            subject.add(mcq);
            easyCount++;
          }
        }
        else if (mcq.difficulty == 'Normal' && normalCount < totalNormalCount) {
          if (!subject.contains(mcq)) {
            subject.add(mcq);
            normalCount++;
          }
        }
        else if (mcq.difficulty == 'Hard' && hardCount < totalHardCount) {
          if (!subject.contains(mcq)) {
            subject.add(mcq);
            hardCount++;
          }
        }

        if (easyCount == totalEasyCount && normalCount == totalNormalCount && hardCount == totalHardCount)
          break;
      }
    });

    for (int i = 0; i < subject.length; i++) {
      if (subject[i].difficulty == 'Easy')
        subjectMCQs.add(subject[i]);
    }

    for (int i = 0; i < subject.length; i++) {
      if (subject[i].difficulty == 'Normal')
        subjectMCQs.add(subject[i]);
    }

    for (int i = 0; i < subject.length; i++) {
      if (subject[i].difficulty == 'Hard')
        subjectMCQs.add(subject[i]);
    }
  }
}