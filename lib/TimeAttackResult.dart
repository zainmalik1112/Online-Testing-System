import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';

class TimeAttackResult extends StatefulWidget {

  final int totalQuestions;
  final int attempted;

  TimeAttackResult({this.totalQuestions,this.attempted});

  @override
  _TimeAttackResultState createState() => _TimeAttackResultState(
    totalQuestions: this.totalQuestions,
    attempted: this.attempted
  );
}

class _TimeAttackResultState extends State<TimeAttackResult> {

  final int totalQuestions;
  final int attempted;
  String timeManagement;

  _TimeAttackResultState({this.totalQuestions,this.attempted});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(attempted < 20){
      timeManagement = "Poor";
    }
    else if(attempted >= 20 && attempted < 25){
      timeManagement = "Good";
    }
    else if(attempted >= 25){
      timeManagement = "Excellent";
    }
  }

  Future<bool> _willPopCallback() async {
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
    // await showDialog or Show add banners or whatever
    // then
    return false;// return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.pink,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: (){
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Time Attack Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontFamily: "Times New Roman",
            ),
          ),
        ),
        body: buildBody(),
      ),
    );
  }

  buildBody()
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: Text(
              'PERFORMANCE CRITERIA:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Poor = Questions attempted less than 20',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Good = Questions attempted 20-25',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Excellent = Questions attempted more than 25',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),

          Container(
            height: 200,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: AppColors.containerColor(),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total Questions: $totalQuestions',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 25.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Attempted: $attempted',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 25.0,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Time Management: $timeManagement',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 25.0
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
