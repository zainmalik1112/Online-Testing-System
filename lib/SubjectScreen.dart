import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ChapterScreen.dart';

class SubjectScreen extends StatefulWidget {

  final String test;
  final currentUserID;
  SubjectScreen({this.test,this.currentUserID});

  @override
  _SubjectScreenState createState() => _SubjectScreenState(
      test: this.test,
      currentUserID: this.currentUserID
  );
}

class _SubjectScreenState extends State<SubjectScreen> {

  final currentUserID;
  String test;
  _SubjectScreenState({this.test,this.currentUserID});

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
    String subject;
    String test;

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
        onTap: (){
          test = title;
          subject = subjectName;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterScreen(test: test,subject: subject, currentUserID: currentUserID),
            ),
          );
        },
      )
    );
  }
}
