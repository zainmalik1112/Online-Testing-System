import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/MCQ.dart';

class ViewChallengeQuestions extends StatefulWidget {

  final List<MCQ> questions;
  ViewChallengeQuestions({this.questions});

  @override
  _ViewChallengeQuestionsState createState() => _ViewChallengeQuestionsState(
    questions: this.questions,
  );
}

class _ViewChallengeQuestionsState extends State<ViewChallengeQuestions> {

  final List<MCQ> questions;
  _ViewChallengeQuestionsState({this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Challenge Questions',
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
    return Swiper(
      itemBuilder: (BuildContext context,int index){
        return buildScreen(
          questions[index].statement,
          questions[index].opA,
          questions[index].opB,
          questions[index].opC,
          questions[index].opD,
          questions[index].correctAnswer,
          questions[index].explanation,
        );
      },
      itemCount: questions.length,
      pagination: SwiperPagination(),
      loop: false,
      scale: 0.6,
    );
  }

  buildScreen(String statement, String opA, String opB, String opC, String opD, String correctAnswer,String explanation)
  {
    return ListView(
      children: <Widget>[
        buildStatement(statement),
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

  buildStatement(String statement)
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
