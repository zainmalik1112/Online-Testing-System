import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/Instructions.dart';

class InstructionScreen extends StatefulWidget {

  final testType;
  final test;

  InstructionScreen({this.testType,this.test});

  @override
  _InstructionScreenState createState() => _InstructionScreenState(
    testType: this.testType,
    test: this.test,
  );
}

class _InstructionScreenState extends State<InstructionScreen> {

  final testType;
  final test;

  _InstructionScreenState({this.testType,this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Instructions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Times New Roman"
          ),
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody()
  {
    String displayInstruction;

    if(testType == 'Practice'){
      displayInstruction = Instructions().getPracticeTestInstruction();
    }
    else if(testType == 'FullFledge' && test == 'ECAT'){
      displayInstruction = Instructions().getECATInstruction();
    }
    else if(testType == 'FullFledge' && test == 'NET'){
      displayInstruction = Instructions().getNETInstruction();
    }
    else if(testType == 'FullFledge' && test == 'FAST-NU'){
      displayInstruction = Instructions().getFASTInstruction();
    }

    return ListView(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Instructions:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: AppColors.containerColor(),
              ),
              child: Text(
                displayInstruction,
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 25.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
