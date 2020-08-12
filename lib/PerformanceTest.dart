import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ExamPerformanceGraph.dart';
import 'package:fun/PerformanceSubject.dart';

class PerformanceTest extends StatefulWidget {

  final currentUserID;

  PerformanceTest({this.currentUserID});

  @override
  _PerformanceTestState createState() => _PerformanceTestState(
    currentUserID: this.currentUserID,
  );
}

class _PerformanceTestState extends State<PerformanceTest> {

  final currentUserID;

  _PerformanceTestState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildPage();
  }

  Scaffold buildPage() {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(
            'View Performance',
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
                buildContainer('images/ecat.jpg','ECAT'),
                buildContainer('images/net.png','NET'),
                buildContainer('images/fast.JPG','FAST-NU'),
                buildContainer('images/nts.jpg','NTS'),
                buildContainer('images/fullFledge.png','Full-Fledge Exam'),
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

          if(test == 'ECAT' || test == 'NET' || test == 'FAST-NU' || test == 'NTS'){
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PerformanceSubject(currentUserID: currentUserID, test: test)
                )
            );
          }
          else{
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => ExamPerformanceGraph(currentUserID: currentUserID)
             )
           );
          }
        },
      ),
    );
  }
}
