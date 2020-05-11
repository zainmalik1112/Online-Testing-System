import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';

class ViewMCQ extends StatefulWidget {

  final String statement;
  final String opA;
  final String opB;
  final String opC;
  final String opD;
  final String explanation;
  final String correctAnswer;

  ViewMCQ({this.statement,this.opA,this.opB,this.opC,this.opD,this.explanation,this.correctAnswer});

  @override
  _ViewMCQState createState() => _ViewMCQState(
    statement: this.statement,
    opA: this.opA,
    opB: this.opB,
    opC: this.opC,
    opD: this.opD,
    correctAnswer: this.correctAnswer,
    explanation: this.explanation,
  );
}

class _ViewMCQState extends State<ViewMCQ> {

  final String statement;
  final String opA;
  final String opB;
  final String opC;
  final String opD;
  final String explanation;
  final String correctAnswer;

  _ViewMCQState({this.statement,this.opA,this.opB,this.opC,this.opD,this.explanation,this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'MCQ Detail',
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
        buildStatement(),
        buildOption(opA,'A.'),
        buildOption(opB,'B.'),
        buildOption(opC,'C.'),
        buildOption(opD,'D.'),
        Padding(
          padding: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0, bottom: 10.0),
          child: Text(
            'Correct Answer:',
            style: TextStyle(
              fontSize: 22.0,
              color: Colors.lightGreenAccent,
            ),
          ),
        ),
        buildCorrectAnswer(correctAnswer),
        Padding(
          padding: EdgeInsets.only(top: 20.0, right: 20.0, left: 20.0, bottom: 10.0),
          child: Text(
            'Explanation:',
            style: TextStyle(
              fontSize: 22.0,
              color: AppColors.textColor(),
            ),
          ),
        ),
        buildExplanation(explanation),
      ],
    );
  }

  buildStatement()
  {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Text(
          statement,
          style: TextStyle(
            fontSize: 22.0,
            color: AppColors.textColor(),
          ),
        ),
      ),
    );
  }

  buildOption(String option, String optionName)
  {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppColors.containerColor(),
        ),
        child: ListTile(
          leading: Text(
            optionName,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor(),
            )
          ),

          title: Text(
            option,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor(),
            ),
          ),
        ),
      ),
    );
  }

  buildCorrectAnswer(String answer)
  {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, bottom: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppColors.containerColor(),
        ),
        child: ListTile(
          leading: Icon(
            Icons.check,
            color: Colors.green,
            size: 25.0,
          ),

          title: Text(
            answer,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor(),
            ),
          ),
        ),
      ),
    );
  }

  buildExplanation(String explanation)
  {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, bottom: 4.0),
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppColors.containerColor(),
        ),
        child: Text(
          explanation,
          style: TextStyle(
            color: AppColors.textColor(),
            fontSize: 22.0,
          )
        )
      ),
    );
  }
}
