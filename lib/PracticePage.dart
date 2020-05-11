import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/SubjectScreen.dart';
import 'package:fun/TimeAttackTest.dart';


class PracticePage extends StatefulWidget {

  final currentUserID;

  PracticePage({this.currentUserID});

  @override
  _PracticePageState createState() => _PracticePageState(currentUserID: this.currentUserID);
}

class _PracticePageState extends State<PracticePage> {

  final currentUserID;

  _PracticePageState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildPracticePage();
  }

  Scaffold buildPracticePage() {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              buildContainer('images/ecat.jpg','ECAT'),
              buildContainer('images/net.png','NET'),
              buildContainer('images/fast.JPG','FAST-NU'),
              buildContainer('images/timeAttack.png','TIME ATTACK'),
            ],
          )
        )
    );
  }

  buildContainer(String imageName, String title)
  {
    String test;
    return Padding(
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
                width: 160,
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
        onTap: (){
          test = title;
          if(test == 'TIME ATTACK'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimeAttackTest()
              )
            );
          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubjectScreen(test: test, currentUserID: currentUserID),
              ),
            );
          }
        },
      ),
    );
  }
}