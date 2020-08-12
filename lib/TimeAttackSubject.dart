import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fun/MCQ.dart';
import 'package:fun/TimeAttackMcq.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'AppColors.dart';
import 'dart:math' as math;

class TimeAttackSubject extends StatefulWidget {

  final String test;
  TimeAttackSubject({this.test});
  @override
  _TimeAttackSubjectState createState() => _TimeAttackSubjectState(
    test: this.test,
  );
}

class _TimeAttackSubjectState extends State<TimeAttackSubject> {

  bool progress = false;
  List<MCQ> timeAttack = [];
  final String test;
  _TimeAttackSubjectState({this.test});

  @override
  Widget build(BuildContext context) {
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
        ),
        body: SafeArea(
            child: ModalProgressHUD(
              inAsyncCall: progress,
              child: ListView(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                      child: Text(
                          'Choose Subject',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: AppColors.textColor(),
                          )
                      )
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: subjects(),
                  )
                ],
              ),
            )
        )
    );
  }

  List<Widget> subjects()
  {
    List<Widget> list = [];

    if(test == 'ECAT'){
      list.add(buildSubjectNameContainer(test,'images/chemistry.png','Chemistry'));
      list.add(buildSubjectNameContainer(test,'images/physics.png','Physics'));
      list.add(buildSubjectNameContainer(test,'images/maths.png','Mathematics'));
      list.add(buildSubjectNameContainer(test,'images/computerScience.png','Computer Science'));
      list.add(buildSubjectNameContainer(test,'images/english.png','English'));
    }
    else if(test == 'NET'){
      list.add(buildSubjectNameContainer(test,'images/chemistry.png','Chemistry'));
      list.add(buildSubjectNameContainer(test,'images/physics.png','Physics'));
      list.add(buildSubjectNameContainer(test,'images/maths.png','Mathematics'));
      list.add(buildSubjectNameContainer(test,'images/computerScience.png','Computer Science'));
      list.add(buildSubjectNameContainer(test,'images/english.png','English'));
      list.add(buildSubjectNameContainer(test, 'images/IQ.png', 'Intelligence'));
    }
    else if(test == 'NTS'){
      list.add(buildSubjectNameContainer(test,'images/chemistry.png','Chemistry'));
      list.add(buildSubjectNameContainer(test,'images/physics.png','Physics'));
      list.add(buildSubjectNameContainer(test,'images/maths.png','Mathematics'));
      list.add(buildSubjectNameContainer(test,'images/computerScience.png','Computer Science'));
      list.add(buildSubjectNameContainer(test,'images/english.png','English'));
      list.add(buildSubjectNameContainer(test, 'images/IQ.png', 'Intelligence'));
    }
    else{
      list.add(buildSubjectNameContainer(test, 'images/basicMaths.png', 'Basic Mathematics'));
      list.add(buildSubjectNameContainer(test,'images/maths.png','Mathematics'));
      list.add(buildSubjectNameContainer(test,'images/physics.png','Physics'));
      list.add(buildSubjectNameContainer(test,'images/english.png','English'));
      list.add(buildSubjectNameContainer(test, 'images/IQ.png', 'Intelligence'));
    }
    return list;
  }

  buildSubjectNameContainer(String title, String imageName, String subjectName)
  {
    return Padding(
        padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                color: AppColors.containerColor(),
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Image(
                    image: AssetImage(imageName),
                    height: 100.0,
                  ),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                          subjectName,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: AppColors.textColor(),
                          )
                      )
                  )
                ],
              )
          ),
            onTap: () async{
            String test = title;
            String subject = subjectName;
              setState(() {
                progress = true;
              });

              await prepareTimeAttack(test, subject);

              setState(() {
                progress = false;
              });

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TimeAttackMcq(subject: subject, test: test, timeAttack: timeAttack)
                  )
              );
            }
        )
    );
  }

  prepareTimeAttack(String test, String subject) async{
    int count = 0;
    await Firestore.instance.collection(test)
        .where('test', isEqualTo: test)
        .where('subject', isEqualTo: subject)
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

         if(!timeAttack.contains(mcq)){
           timeAttack.add(mcq);
           count++;
         }

         if(count == 30)
           break;
       }
    });
  }
}
