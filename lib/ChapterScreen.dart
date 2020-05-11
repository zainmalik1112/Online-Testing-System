import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/Chapters.dart';
import 'package:fun/InstructionScreen.dart';
import 'package:fun/MCQ.dart';
import 'package:fun/McqScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:math' as math;
class ChapterScreen extends StatefulWidget {

  final String test;
  final String subject;
  final currentUserID;
  ChapterScreen({this.test,this.subject,this.currentUserID});

  @override
  _ChapterScreenState createState() => _ChapterScreenState(
      test: this.test,
      subject: this.subject,
      currentUserID: this.currentUserID,
  );
}

class _ChapterScreenState extends State<ChapterScreen> {

  String test;
  String subject;
  final currentUserID;
  List<String> chapters;
  bool progress = false;
  List<MCQ> practiceTest = [];

  _ChapterScreenState({this.test,this.subject,this.currentUserID});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
        test+'-'+subject,
        style: TextStyle(
        fontFamily: "Times New Roman",
        color: Colors.white,
        fontSize: 25,
    ),
    ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                child: Icon(
                  Icons.subject,
                  color: Colors.white,
                  size: 30.0,
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstructionScreen(
                        testType: 'Practice',
                      )
                    )
                  );
                },
              ),
            )
          ],
    ),
       body: ModalProgressHUD(
         inAsyncCall: progress,
         child: SafeArea(
           child: ListView(
             children: listMyWidgets(),
           )
         ),
       ),
     );
  }

  showAlertDialogue(String message){
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

  List<Widget> listMyWidgets() {

    if(subject == 'Chemistry')
      chapters = Chapters.getChemistryChapters();
    else if(subject == 'Physics')
      chapters = Chapters.getPhysicsChapters();
    else if(subject == 'Mathematics')
      chapters = Chapters.getMathChapters();
    else if(subject == 'Computer Science')
      chapters = Chapters.getCSChapters();
    else if(subject == 'Intelligence')
      chapters = Chapters.getIQChapters();
    else if(subject == 'Basic Mathematics')
      chapters = Chapters.getBasicMathChapters();
    else if(subject == 'English')
      chapters = ['Synonyms','Antonyms','Idioms/Phrases','Sentence Correction'];

    List<Widget> list = new List();
    list.add(
      Padding(
        padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 8.00),
        child: Text(
          'Select Chapter',
          style: TextStyle(
            fontSize: 22.0,
            color: AppColors.textColor(),
          )
        )
      )
    );
    for(var i in chapters){
      list.add(buildContainer(test, subject, i));
    }
    return list;
  }

  buildContainer(String title, String subjectName, String chapterName)
  {
    String test;
    String subject;
    String chapter;

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.containerColor(),
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: EdgeInsets.all(8.0),
          child: Text(
            chapterName,
            style: TextStyle(
              fontSize: 25.0,
              color: AppColors.textColor(),
            )
          ),
        ),
        onTap: () async{
          test = title;
          subject = subjectName;
          chapter = chapterName;

          setState(() {
            progress = true;
          });

          if(subject == 'Basic Mathematics' || subject == 'Intelligence') {
            try {
              await prepareBasicMathOrIQPracticeTest(test, subject, chapter);
            }
            catch (e) {
              showAlertDialogue(e.toString());
              return;
            }
          }
          else {
            try{
              await preparePracticeTest(test, subject, chapter);
            }
            catch(e){
              showAlertDialogue(e.toString());
              return;
            }
          }

          setState(() {
            progress = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => McqScreen(practiceTest: practiceTest, currentUserID: currentUserID)
            )
          );
        }
      ),
    );
  }

  preparePracticeTest(String test, String subjectName, String chapter) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: subjectName)
        .where('chapter', isEqualTo: chapter)
        .getDocuments().then((QuerySnapshot snapshot){
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

        if(mcq.difficulty == 'easy' && easyCount < 5){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            easyCount++;
          }
        }
        else if(mcq.difficulty == 'normal' && normalCount < 15){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            normalCount++;
          }
        }
        else if(mcq.difficulty == 'hard' && hardCount < 10){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            hardCount++;
          }
        }

        if(easyCount == 5 && normalCount == 15 && hardCount == 10)
          break;
      }
    });

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'easy')
        practiceTest.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'normal')
        practiceTest.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'hard')
        practiceTest.add(subject[i]);
    }
  }

  prepareBasicMathOrIQPracticeTest(String test, String subjectName, String chapter) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: subjectName)
        .where('chapter', isEqualTo: chapter)
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

        if(mcq.difficulty == 'easy' && easyCount < 5){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            easyCount++;
          }
        }
        else if(mcq.difficulty == 'normal' && normalCount < 5){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            normalCount++;
          }
        }
        else if(mcq.difficulty == 'hard' && hardCount < 5){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            hardCount++;
          }
        }

        if(easyCount == 5 && normalCount == 5 && hardCount == 5)
          break;
      }
    });

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'easy')
        practiceTest.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'normal')
        practiceTest.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'hard')
        practiceTest.add(subject[i]);
    }
  }
}
