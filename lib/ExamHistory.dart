import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/ExamQuestions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeago/timeago.dart' as TimeAgo;
import 'AppColors.dart';

class ExamHistory extends StatefulWidget {

  final currentUserID;
  final String test;
  ExamHistory({this.currentUserID,this.test});

  @override
  _ExamHistoryState createState() => _ExamHistoryState(
    currentUserID: this.currentUserID,
    test: this.test,
  );
}

class _ExamHistoryState extends State<ExamHistory> {

  final currentUserID;
  final String test;

  _ExamHistoryState({this.currentUserID,this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Exam History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Times New Roman",
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundColor(),
      body: buildBody(),
    );
  }

  buildBody()
  {
    return ListView(
      children: <Widget>[
        StreamBuilder(
          stream: Firestore.instance.collection('FullTestPerformance')
              .document(currentUserID).collection('TestRecord').orderBy('timestamp', descending: true)
              .snapshots(),

          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(!snapshot.hasData){
              return Center(
                child: SpinKitHourGlass(
                  color: Colors.blueAccent,
                  size: 30.0,
                ),
              );
            }

            var history = snapshot.data.documents;
            List<Widget> testHistory = [];

            for(var test in history){
              final theTest = test.data['test'];
              final testScore = test.data['testScore'];
              final testID = test.data['testID'];
              final correct = test.data['correct'];
              final totalScore = test.data['totalScore'];
              final incorrect = test.data['incorrect'];
              final unattempted = test.data['unattempted'];
              final Timestamp timeStamp = test.data['timestamp'];

              if(theTest == this.test){
                testHistory.add(
                    buildContainer(testScore, correct, totalScore, timeStamp,
                        incorrect,unattempted,testID)
                );
              }
            }

            return testHistory.isEmpty ? Center(
              child: Text(
                'No Test taken yet',
                style: TextStyle(
                  fontSize: 20.0,
                  color: AppColors.textColor(),
                ),
              ),
            ):Column(
              children: testHistory,
            );
          },
        ),
      ],
    );
  }

  buildContainer(int testScore, int correct, int totalScore, Timestamp timestamp,
      int incorrect,int unattempted,String testID)
  {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: AppColors.containerColor(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Score: $testScore/$totalScore',
                    style: TextStyle(
                      fontSize: 25.0,
                      color: AppColors.textColor(),
                    ),
                  ),
                  Text(
                    'Correct Answers: $correct',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: AppColors.textColor(),
                    ),
                  ),
                  Text(
                    'Incorrect Answers: $incorrect',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: AppColors.textColor(),
                    ),
                  ),
                  Text(
                    'Unattempted Questions: $unattempted',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: AppColors.textColor(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          size: 30.0,
                          color: AppColors.textColor(),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            TimeAgo.format(timestamp.toDate()),
                            style: TextStyle(
                              fontSize: 15.0,
                              color: AppColors.textColor(),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),

              CircularPercentIndicator(
                radius: 100,
                lineWidth: 15,
                progressColor: Colors.lightGreenAccent,
                percent: testScore/totalScore,
                center: Text(
                  (testScore/totalScore*100).round().toString() + "%",
                  style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 25.0
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.grey[800],
                animation: true,
              ),

            ],
          ),
        ),

        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ExamQuestions(testID: testID)
              )
          );
        },
      ),
    );
  }
}

