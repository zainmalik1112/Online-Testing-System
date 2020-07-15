import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ViewMCQ.dart';

class TestQuestions extends StatefulWidget {

  final testID;

  TestQuestions({this.testID});

  @override
  _TestQuestionsState createState() => _TestQuestionsState(
      testID: this.testID
  );
}

class _TestQuestionsState extends State<TestQuestions> {

  final testID;
  _TestQuestionsState({this.testID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Questions',
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: "Times New Roman",
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.pink,
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
          stream: Firestore.instance.collection('TestCollections')
              .document(testID).collection('Questions').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(!snapshot.hasData){
              return Center(
                child: SpinKitHourGlass(
                  color: Colors.blueAccent,
                  size: 30.0,
                ),
              );
            }

            var questions = snapshot.data.documents;
            List<Widget> testQuestions = [];

            for(var question in questions){
              final statement = question.data['statement'];
              final opA = question.data['opA'];
              final opB = question.data['opB'];
              final opC = question.data['opC'];
              final opD = question.data['opD'];
              final correctAnswer = question.data['correctAnswer'];
              final explanation = question.data['explanation'];

              testQuestions.add(
                  buildContainer(statement, opA, opB, opC, opD, correctAnswer, explanation)
              );
            }

            return Column(
              children: testQuestions,
            );
          },
        )
      ],
    );
  }

  buildContainer(String statement, String opA, opB, opC, opD, String correctAnswer, explanation)
  {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: AppColors.containerColor(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Question Statement:',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 22,
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward,
                    size: 35.0,
                    color: AppColors.textColor(),
                  ),
                ],
              ),

              SizedBox(
                height: 10.0,
              ),

              Text(
                statement,
                style: TextStyle(
                    color: AppColors.textColor(),
                    fontSize: 20.0
                ),
              )
            ],
          ),
        ),

        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewMCQ(
                    statement: statement,
                    opA: opA,
                    opB: opB,
                    opC: opC,
                    opD: opD,
                    correctAnswer: correctAnswer,
                    explanation: explanation,
                  )
              )
          );
        },
      ),
    );
  }
}
