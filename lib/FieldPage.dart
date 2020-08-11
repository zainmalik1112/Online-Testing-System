import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/EcatNustScreen.dart';
import 'package:fun/InstructionScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'MCQ.dart';
import 'dart:math' as math;

class FieldPage extends StatefulWidget {

  final test;
  final currentUserID;
  FieldPage({this.test,this.currentUserID});

  @override
  _FieldPageState createState() => _FieldPageState(test: this.test, currentUserID: this.currentUserID);
}

class _FieldPageState extends State<FieldPage> {

  final test;
  final currentUserID;
  List<MCQ> exam;
  List<MCQ> subjectMCQs = [];
  bool quit = false;
  bool progress = false;
  _FieldPageState({this.test,this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildFieldPage();
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

  Scaffold buildFieldPage()
  {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          test,
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
                    builder: (context) => InstructionScreen(test: test, testType: 'FullFledge')
                  )
                );
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: progress,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
                child: Text(
                    'Choose chemistry or computer science:',
                  style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0,
                  ),
                ),
              ),
              buildContainer('images/engineering.png','Pre-Engineering'),
              buildContainer('images/computerScience.png','ICS'),
            ],
          ),
        ),
      ),
    );
  }

  buildContainer(String imageName, String title)
  {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        child: GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: AppColors.containerColor(),
              ),
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage(imageName),
                    width: 133,
                  ),

                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 30.0,
                          color: AppColors.textColor(),
                        )
                    ),
                  )
                ],
              )
          ),
          onTap: () async{

            setState(() {
              progress = true;
            });

             if(test == 'ECAT')
               exam = await prepareECAT(title);
             else if(test == 'NET')
               exam = await prepareNET(title);
             else
               exam = await prepareFAST(title);

            setState(() {
              progress = false;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EcatNustScreen(test: test, field: title, fullTest: exam, currentUserID: currentUserID),
              )
            );
          },
        ),
      ),
    );
  }
  
  prepareECAT(String field) async
  {
    List<MCQ> fullTest = [];

    if(field == 'Pre-Engineering') {
      try {
        await prepareECATScienceSubject('Physics');
        await prepareECATScienceSubject('Mathematics');
        await prepareECATEnglish();
        await prepareECATScienceSubject('Chemistry');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }
    else {
      try {
        await prepareECATScienceSubject('Physics');
        await prepareECATScienceSubject('Mathematics');
        await prepareECATEnglish();
        await prepareECATScienceSubject('Computer Science');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }

    fullTest = subjectMCQs;
    return fullTest;
  }
  
  prepareECATScienceSubject(String name) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: name)
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

        if(mcq.difficulty == 'Easy' && easyCount < 5){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            easyCount++;
          }
        }
        else if(mcq.difficulty == 'Normal' && normalCount < 15){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            normalCount++;
          }
        }
        else if(mcq.difficulty == 'Hard' && hardCount < 10){
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
      if(subject[i].difficulty == 'Easy')
        subjectMCQs.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'Normal')
        subjectMCQs.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'Hard')
        subjectMCQs.add(subject[i]);
    }
  }

  prepareECATEnglish() async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: 'English')
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

        if(mcq.difficulty == 'Easy' && easyCount < 2){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            easyCount++;
          }
        }
        else if(mcq.difficulty == 'Normal' && normalCount < 4){
          if(!subject.contains(mcq)) {
            subject.add(mcq);
            normalCount++;
          }
        }
        else if(mcq.difficulty == 'Hard' && hardCount < 4){
          if(!subject.contains(mcq)){
            subject.add(mcq);
            hardCount++;
          }
        }

        if(easyCount == 2 && normalCount == 4 && hardCount == 4)
          break;
      }
    });

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'Easy')
        subjectMCQs.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'Normal')
        subjectMCQs.add(subject[i]);
    }

    for(int i = 0; i < subject.length; i++){
      if(subject[i].difficulty == 'Hard')
        subjectMCQs.add(subject[i]);
    }
  }

  prepareNET(String field) async
  {
    List<MCQ> fullTest = [];

    if(field == 'Pre-Engineering') {
      try {
        await prepareNETSubjects('Mathematics');
        await prepareNETSubjects('Physics');
        await prepareNETSubjects('Chemistry');
        await prepareNETSubjects('English');
        await prepareNETSubjects('Intelligence');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }
    else {
      try {
        await prepareNETSubjects('Mathematics');
        await prepareNETSubjects('Physics');
        await prepareNETSubjects('Computer Science');
        await prepareNETSubjects('English');
        await prepareNETSubjects('Intelligence');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }

    fullTest = subjectMCQs;
    return fullTest;
  }

  prepareNTS(String field) async
  {
    List<MCQ> fullTest = [];

    if(field == 'Pre-Engineering') {
      try {
        await prepareNTSSubjects('Mathematics');
        await prepareNTSSubjects('Physics');
        await prepareNTSSubjects('Chemistry');
        await prepareNTSSubjects('English');
        await prepareNTSSubjects('Intelligence');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }
    else {
      try {
        await prepareNTSSubjects('Mathematics');
        await prepareNTSSubjects('Physics');
        await prepareNTSSubjects('Computer Science');
        await prepareNTSSubjects('English');
        await prepareNTSSubjects('Intelligence');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }

    fullTest = subjectMCQs;
    return fullTest;
  }

  prepareFAST(String field) async
  {
    List<MCQ> fullTest = [];
    if(field == 'Pre-Engineering'){
      try{
        await prepareFASTEngineeringSubjects('Basic Mathematics');
        await prepareFASTEngineeringSubjects('Mathematics');
        await prepareFASTEngineeringSubjects('Physics');
        await prepareFASTEngineeringSubjects('Intelligence');
        await prepareFASTEngineeringSubjects('English');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
      }
    }
    else{
      try{
        await prepareFASTCSSubjects('Basic Mathematics');
        await prepareFASTCSSubjects('Mathematics');
        await prepareFASTCSSubjects('Intelligence');
        await prepareFASTCSSubjects('English');
      }
      catch(e){
        showAlertDialogue(e.toString());
        return;
    }
    }

    fullTest = subjectMCQs;
    return fullTest;
  }

  prepareNETSubjects(String name) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;
    int totalEasyCount;
    int totalNormalCount;
    int totalHardCount;

    if (name == 'Mathematics') {
      totalEasyCount = 10;
      totalNormalCount = 50;
      totalHardCount = 20;
    }
    else if (name == 'Physics') {
      totalEasyCount = 10;
      totalNormalCount = 30;
      totalHardCount = 20;
    }
    else if (name == 'Chemistry' || name == 'Computer Science') {
      totalEasyCount = 5;
      totalNormalCount = 15;
      totalHardCount = 10;
    }
    else if (name == 'English') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'Intelligence') {
      totalEasyCount = 2;
      totalNormalCount = 3;
      totalHardCount = 5;
    }

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: name)
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

  prepareFASTEngineeringSubjects(String name) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;
    int totalEasyCount;
    int totalNormalCount;
    int totalHardCount;

    if (name == 'Mathematics') {
      totalEasyCount = 5;
      totalNormalCount = 15;
      totalHardCount = 20;
    }
    else if (name == 'Physics') {
      totalEasyCount = 5;
      totalNormalCount = 5;
      totalHardCount = 10;
    }
    else if (name == 'Basic Mathematics') {
      totalEasyCount = 2;
      totalNormalCount = 5;
      totalHardCount = 3;
    }
    else if (name == 'English') {
      totalEasyCount = 2;
      totalNormalCount = 5;
      totalHardCount = 3;
    }
    else if (name == 'Intelligence') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: name)
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

  prepareFASTCSSubjects(String name) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;
    int totalEasyCount;
    int totalNormalCount;
    int totalHardCount;

    if (name == 'Mathematics') {
      totalEasyCount = 5;
      totalNormalCount = 25;
      totalHardCount = 20;
    }
    else if (name == 'Basic Mathematics') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'English') {
      totalEasyCount = 2;
      totalNormalCount = 5;
      totalHardCount = 3;
    }
    else if (name == 'Intelligence') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: name)
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

  prepareNTSSubjects(String name) async
  {
    List<MCQ> subject = [];
    int easyCount = 0;
    int normalCount = 0;
    int hardCount = 0;
    int totalEasyCount;
    int totalNormalCount;
    int totalHardCount;

    if (name == 'Mathematics') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'Physics') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'Chemistry' || name == 'Computer Science') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'English') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }
    else if (name == 'Intelligence') {
      totalEasyCount = 5;
      totalNormalCount = 10;
      totalHardCount = 5;
    }

    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: name)
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
