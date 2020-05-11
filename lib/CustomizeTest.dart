import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CustomizeTime.dart';
import 'package:fun/CustomizedSubject.dart';

class CustomizeTest extends StatefulWidget {

  final String test;
  CustomizeTest({this.test});

  @override
  _CustomizeTestState createState() => _CustomizeTestState(
    test: this.test,
  );
}

class _CustomizeTestState extends State<CustomizeTest> {

  final String test;
  List<CustomizedSubject> subjects = [];
  String totalLength = "";
  _CustomizeTestState({this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Customized Test',
          style: TextStyle(
            fontSize: 25.0,
            fontFamily: "Times New Roman"
          )
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          buildTotalQuestionContainer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlineButton(
               borderSide: BorderSide.none,
               child: Text(
                 'NEXT',
                 style: TextStyle(
                   color: Colors.pink,
                   fontSize: 25.0,
                 ),
               ),
                onPressed: (){
                 if(totalLength.isEmpty)
                   return;

                 if(num.tryParse(totalLength) < 15 || num.tryParse(totalLength) > 200)
                   return;

                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => CustomizeTime(totalLength: totalLength, test: test)
                   )
                 );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  inputDecoration()
  {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.pink,
        ),
        borderRadius: BorderRadius.circular(32.0),
      ),
    );
  }

  buildTotalQuestionContainer()
  {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          color: AppColors.containerColor(),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Enter the total number of questions in the test(between 15 and 200):',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              width: 80,
              child: TextField(
                maxLength: 3,
                maxLengthEnforced: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                decoration: inputDecoration(),
                onChanged: (value){
                    totalLength = value;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
