import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun/AddSubjectScreen.dart';
import 'package:fun/AppColors.dart';

class CustomizeTime extends StatefulWidget {

  final String totalLength;
  final test;

  CustomizeTime({this.test,this.totalLength});

  @override
  _CustomizeTimeState createState() => _CustomizeTimeState(
    totalLength: this.totalLength,
    test: this.test,
  );
}

class _CustomizeTimeState extends State<CustomizeTime> {

  final String totalLength;
  final test;
  String minutes = "";
  String seconds = "";

  _CustomizeTimeState({this.totalLength,this.test});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Time Constraint',
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
    return SafeArea(
      child: ListView(
        children: <Widget>[
          buildMinutesContainer(),
          buildSecondsContainer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              OutlineButton(
                borderSide: BorderSide.none,
                child: Text(
                  'NEXT',
                  style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.pink
                  ),
                ),
                onPressed: (){
                  if(minutes.isEmpty || seconds.isEmpty)
                    return;

                  if(num.tryParse(minutes) <= 0 || num.tryParse(minutes) > 200 || num.tryParse(seconds) > 59)
                    return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddSubjectScreen(
                        theTest: test,
                        totalLength: totalLength,
                        minutes: num.tryParse(minutes),
                        seconds: num.tryParse(seconds),
                      )
                    )
                  );

                },
              ),
            ],
          )
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

  buildMinutesContainer()
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
                'Enter starting time of minutes(must not be 0 and more than 200):',
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
                  minutes = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Suggested time according to length of test: '+ (num.tryParse(totalLength) + 5).toString(),
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 17.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildSecondsContainer()
  {
    return Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
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
                'Enter starting time of seconds(must not be more than 59):',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),
            ),
            Container(
              width: 80,
              child: TextField(
                maxLength: 2,
                maxLengthEnforced: true,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                decoration: inputDecoration(),
                onChanged: (value){
                  seconds = value;
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
