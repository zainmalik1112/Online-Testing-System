import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ViewMCQ.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';

import 'MCQ.dart';

class PerformanceScreen extends StatefulWidget {

  final testType;
  final double correct;
  final double incorrect;
  final double attempted;
  final double unattempted;
  final double testScore;
  final double totalQuestions;
  final double totalMarks;
  final List<MCQ> questions;
  final List<String> selectedOptions;

  PerformanceScreen({this.questions,this.correct,this.incorrect,this.attempted,this.unattempted,
  this.testScore, this.totalQuestions,this.totalMarks,this.testType,this.selectedOptions});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState(
    correct: this.correct,
    incorrect: this.incorrect,
    attempted: this.attempted,
    unattempted: this.unattempted,
    testScore: this.testScore,
    totalQuestions: this.totalQuestions,
    totalMarks: this.totalMarks,
    testType: this.testType,
    questions: this.questions,
    selectedOptions: this.selectedOptions,
  );
}

class _PerformanceScreenState extends State<PerformanceScreen> {

  final testType;
  final double correct;
  final double incorrect;
  final double attempted;
  final double unattempted;
  final double testScore;
  final double totalQuestions;
  final double totalMarks;
  final List<MCQ> questions;
  final List<String> selectedOptions;
  Map<String, double> dataMap = new Map();
  Map<String, double> dataMap2 = new Map();

  _PerformanceScreenState({this.questions,this.correct,this.incorrect,this.attempted,this.unattempted,
    this.testScore, this.totalQuestions,this.totalMarks,this.testType,this.selectedOptions});


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataMap.putIfAbsent("Attempted", ()=> attempted);
    dataMap.putIfAbsent("Unattempted", ()=> unattempted);

    dataMap2.putIfAbsent("Correct", ()=> correct);
    dataMap2.putIfAbsent('Incorrect', ()=> incorrect);
    dataMap2.putIfAbsent('Not Attempted', ()=> unattempted);
  }

  Future<bool> _willPopCallback() async {
    if(testType == 'Practice'){
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
    else{
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    }
    // await showDialog or Show add banners or whatever
    // then
    return false; // return true if the route to be popped
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.pink,
          title: Text(
              'Test Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: "Times New Roman",
            ),
          ),
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back,
              size: 30,
            ),
            onTap: () {
              if(testType == 'Practice'){
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              }
              else{
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
          ),
        ),
        backgroundColor: AppColors.backgroundColor(),
        body: buildBody(),
      ),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: buildContainer('Total Questions', totalQuestions.round().toString(),
                150, double.infinity),
          ),
          buildStatisticContainer('Attempted', attempted.round().toString()+'/'+totalQuestions.round().toString(),
              300, double.infinity, true),
          buildStatisticContainer('Correct Answers', correct.round().toString()+'/'+totalQuestions.round().toString(),
              300, double.infinity, true),
          buildStatisticContainer('Test Score', testScore.round().toString()+'/'+
              totalMarks.round().toString()
              , 200, double.infinity, false),
          buildQuestionContainer(),
        ],
      ),
    );
  }

  buildContainer(String text, String number, double height, double width)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppColors.containerColor(),
        ),
        padding: EdgeInsets.all(8.0),
        width: width,
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 30,
                ),
              ),

              SizedBox(
                height: 10,
              ),

              Text(
                number,
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildStatisticContainer(String text, String number, double height, double width, bool pieChart) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppColors.containerColor(),
        ),
        padding: EdgeInsets.all(8.0),
        width: width,
        height: height,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 155.0,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 30,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  Text(
                    number,
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 30.0,
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                ],
              ),

              SizedBox(
                width: 20.0,
              ),

              Material(
                borderRadius: BorderRadius.circular(30.0),
                elevation: 20.0,
                color: AppColors.containerColor(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: pieChart == false ? CircularPercentIndicator(
                    radius: 140,
                    lineWidth: 15,
                    progressColor: Colors.lightGreenAccent,
                    percent: testScore < 0 ? 0 : testScore/totalMarks,
                    center: Text(
                        testScore < 0 ? "0%":((testScore/totalMarks)*100).round().toString() + "%",
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 35.0
                        )
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.grey[800],
                    animation: true,
                  ):
                  PieChart(
                    chartRadius: 100.0,
                    dataMap: text == 'Attempted' ? dataMap : dataMap2,
                    showChartValuesInPercentage: false,
                    legendPosition: LegendPosition.bottom,
                    chartValueStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                    chartType: ChartType.ring,
                    showChartValuesOutside: true,
                    legendStyle: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 20.0,
                    ),
                    colorList: text == 'Attempted' ? [Colors.pink[300], Colors.lightBlue[300]] :
                     [Colors.green, Colors.pink, Colors.purpleAccent],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildQuestionContainer()
  {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: AppColors.containerColor()
        ),
        height: 510,
        child: ListView(
          children: <Widget>[
            DataTable(
              columns: [
                DataColumn(
                    label: Text(
                        'Question Number',
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 20.0,
                      ),
                    )
                ),
                DataColumn(
                    label: Text(
                        'Status',
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 20.0,
                      ),
                    )
                )
              ],
             rows: getRows(),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> getRows()
  {
    List<DataRow> list = [];

    for(int i = 0; i < questions.length; i++){
      if(selectedOptions[i] == questions[i].correctAnswer){
        list.add(
          DataRow(
            cells: [
              DataCell(
                  Center(
                    child: GestureDetector(
                      child: Text(
                          (i+1).toString(),
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 20.0,
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewMCQ(
                              statement: questions[i].statement,
                              opA: questions[i].opA,
                              opB: questions[i].opB,
                              opC: questions[i].opC,
                              opD: questions[i].opD,
                              correctAnswer: questions[i].correctAnswer,
                              explanation: questions[i].explanation,
                            )
                          )
                        );
                      },
                    ),
                  )
              ),
              DataCell(
                GestureDetector(
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 30.0,
                  ),
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewMCQ(
                              statement: questions[i].statement,
                              opA: questions[i].opA,
                              opB: questions[i].opB,
                              opC: questions[i].opC,
                              opD: questions[i].opD,
                              correctAnswer: questions[i].correctAnswer,
                              explanation: questions[i].explanation,
                            )
                        )
                    );
                  },
                ),
              ),
            ]
          )
        );
      }
      else if(selectedOptions[i] != questions[i].correctAnswer && selectedOptions[i] != null){
        list.add(
            DataRow(
                cells: [
                  DataCell(
                      Center(
                        child: GestureDetector(
                          child: Text(
                              (i+1).toString(),
                            style: TextStyle(
                              color: AppColors.textColor(),
                              fontSize: 20.0,
                            ),
                          ),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewMCQ(
                                      statement: questions[i].statement,
                                      opA: questions[i].opA,
                                      opB: questions[i].opB,
                                      opC: questions[i].opC,
                                      opD: questions[i].opD,
                                      correctAnswer: questions[i].correctAnswer,
                                      explanation: questions[i].explanation,
                                    )
                                )
                            );
                          },
                        ),
                      )
                  ),
                  DataCell(
                    GestureDetector(
                      child: Icon(
                        Icons.clear,
                        color: Colors.red,
                        size: 30.0,
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewMCQ(
                                  statement: questions[i].statement,
                                  opA: questions[i].opA,
                                  opB: questions[i].opB,
                                  opC: questions[i].opC,
                                  opD: questions[i].opD,
                                  correctAnswer: questions[i].correctAnswer,
                                  explanation: questions[i].explanation,
                                )
                            )
                        );
                      },
                    ),
                  ),
                ]
            )
        );
      }
      else if(selectedOptions[i] == null){
        list.add(
            DataRow(
                cells: [
                  DataCell(
                      Center(
                        child: GestureDetector(
                          child: Text(
                              (i+1).toString(),
                            style: TextStyle(
                              color: AppColors.textColor(),
                              fontSize: 20.0,
                            ),
                          ),
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewMCQ(
                                      statement: questions[i].statement,
                                      opA: questions[i].opA,
                                      opB: questions[i].opB,
                                      opC: questions[i].opC,
                                      opD: questions[i].opD,
                                      correctAnswer: questions[i].correctAnswer,
                                      explanation: questions[i].explanation,
                                    )
                                )
                            );
                          },
                        ),
                      )
                  ),
                  DataCell(
                    GestureDetector(
                      child: Text(
                          'Unattempted',
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 18.0,
                        ),
                      ),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewMCQ(
                                  statement: questions[i].statement,
                                  opA: questions[i].opA,
                                  opB: questions[i].opB,
                                  opC: questions[i].opC,
                                  opD: questions[i].opD,
                                  correctAnswer: questions[i].correctAnswer,
                                  explanation: questions[i].explanation,
                                )
                            )
                        );
                      },
                    ),
                  ),
                ]
            )
        );
      }
    }

    return list;
  }
}





