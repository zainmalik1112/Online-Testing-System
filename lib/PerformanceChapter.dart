import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/Chapters.dart';
import 'package:fun/PracticeGraph.dart';

class PerformanceChapter extends StatefulWidget {

  final currentUserID;
  final String test;
  final String subject;

  PerformanceChapter({this.currentUserID,this.test,this.subject});

  @override
  _PerformanceChapterState createState() => _PerformanceChapterState(
    currentUserID: this.currentUserID,
    test: this.test,
    subject: this.subject
  );
}

class _PerformanceChapterState extends State<PerformanceChapter> {

  final currentUserID;
  final String test;
  final String subject;
  List<String> chapters;

  _PerformanceChapterState({this.currentUserID,this.subject,this.test});

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
      ),
      body: SafeArea(
          child: ListView(
            children: listMyWidgets(),
          )
      ),
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
        onTap: (){
          test = title;
          subject = subjectName;
          chapter = chapterName;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeGraph(
                test: test,
                subject: subject,
                chapter: chapter,
                currentUserID: currentUserID,
              )
            )
          );
        },
      ),
    );
  }
}
