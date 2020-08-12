import 'package:flutter/material.dart';
import 'package:fun/TimeAttackSubject.dart';

import 'AppColors.dart';

class TimeAttackTest extends StatefulWidget {
  @override
  _TimeAttackTestState createState() => _TimeAttackTestState();
}

class _TimeAttackTestState extends State<TimeAttackTest> {
  @override
  Widget build(BuildContext context) {
    return buildPracticePage();
  }

  Scaffold buildPracticePage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Time Attack',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Times New Roman"
          ),
        ),
      ),
        backgroundColor: AppColors.backgroundColor(),
        body: SafeArea(
            child: ListView(
              children: <Widget>[
                buildContainer('images/ecat.jpg','ECAT'),
                buildContainer('images/net.png','NET'),
                buildContainer('images/fast.JPG','FAST-NU'),
                buildContainer('images/nts.jpg','NTS'),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimeAttackSubject(test: test)
            )
          );
        },
      ),
    );
  }
}
