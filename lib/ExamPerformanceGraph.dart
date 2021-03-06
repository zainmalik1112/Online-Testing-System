import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'AppColors.dart';
import 'ExamHistory.dart';

class ExamPerformanceGraph extends StatefulWidget {

  final currentUserID;
  ExamPerformanceGraph({this.currentUserID});

  @override
  _ExamPerformanceGraphState createState() => _ExamPerformanceGraphState(
    currentUserID: this.currentUserID,
  );
}

class _ExamPerformanceGraphState extends State<ExamPerformanceGraph> {

  final currentUserID;
  String test;
  List<charts.Series<Performance,num>> series;

  _ExamPerformanceGraphState({this.currentUserID});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    test = 'ECAT';
    series = List<charts.Series<Performance,num>>();
  }

  initializeData(List<Performance> data)
  {
    series = [
      charts.Series(
        id: 'Performance',
        domainFn: (Performance performance,_) =>
        performance.testNo,
        measureFn: (Performance performance,_) => performance.testScore,
        colorFn: (Performance performance,_) => charts.ColorUtil.fromDartColor(Colors.pink),
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
            'Your Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23.0,
              fontFamily: "Times New Roman",
            )
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.history,
                color: Colors.white,
                size: 35,
              ),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExamHistory(
                          currentUserID: currentUserID,
                          test: test,
                        )
                    )
                );
              },
            ),
          )
        ],
      ),
      backgroundColor: AppColors.backgroundColor(),
      body: buildBody(),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Container(
            width: double.infinity,
            color: AppColors.containerColor(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                radioButton('ECAT'),
                radioButton('NET'),
                radioButton('FAST-NU'),
                radioButton('NTS'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Exam Performance Graph',
              style: TextStyle(
                fontSize: 22.0,
                color: AppColors.textColor(),
              ),
            ),
          ),

          StreamBuilder(
            stream: Firestore.instance.collection('FullTestPerformance')
                .document(currentUserID).collection('TestRecord').orderBy('timestamp', descending: false)
                .snapshots(),

            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(!snapshot.hasData){
                return Center(
                  child: SpinKitHourGlass(
                    color: Colors.blueAccent,
                    size: 30.0,
                  ),
                );
              }

              var history = snapshot.data.documents;
              List<Performance> data = [];
              int totalAttempted = 0;
              int totalCorrect = 0;
              int totalIncorrect = 0;
              int totalUnattempted = 0;
              double totalTestScore = 0;
              double avg;
              double avgUnattempted;
              double avgTestAccuracy;
              Map<String, double> dataMap = new Map();
              Map<String, double> dataMap2 = new Map();
              int i = 0;
              data.add(Performance(testScore: 0, testNo: 0));

              for(var test in history) {
                final theTest = test.data['test'];
                final testScore = test.data['testScore'];
                final attempted = test.data['attempted'];
                final correct = test.data['correct'];
                final incorrect = test.data['incorrect'];
                final unattempted = test.data['unattempted'];
                final totalScore = test.data['totalScore'];

                if (theTest == this.test) {
                  data.add(Performance(
                    testScore: testScore,
                    testNo: i + 1,
                  ));
                  totalAttempted = totalAttempted + attempted;
                  totalCorrect = totalCorrect + correct;
                  totalIncorrect = totalIncorrect + incorrect;
                  totalTestScore = totalTestScore + (testScore/totalScore);
                  totalUnattempted = totalUnattempted + unattempted;
                  i++;
                }
              }

              if(data.isEmpty || data.length == 1){
                return Center(
                  child: Text(
                    'No test taken yet',
                    style: TextStyle(
                      color: AppColors.textColor(),
                      fontSize: 20.0,
                    ),
                  ),
                );
              }

              avg = totalIncorrect/i;
              avgTestAccuracy = totalTestScore/i;
              avgUnattempted = totalUnattempted/i;
              dataMap.putIfAbsent("Total Correct", () => totalCorrect.toDouble());
              dataMap.putIfAbsent("Total Incorrect", () => totalIncorrect.toDouble());
              dataMap2.putIfAbsent("Average Incorrect", () => avg);
              dataMap2.putIfAbsent('Average Unattempted', () => avgUnattempted);
              initializeData(data);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.white,
                      child: SizedBox(
                        height:400.0,
                        child: charts.LineChart(
                          series,
                          defaultRenderer: charts.LineRendererConfig(
                            includeArea: true,
                            stacked: true,
                            includePoints: true,
                          ),
                          animationDuration: Duration(milliseconds: 600),
                          animate: true,
                          behaviors: [
                            charts.ChartTitle(
                              'Exam Number',
                              titleStyleSpec: charts.TextStyleSpec(
                                color: charts.ColorUtil.fromDartColor(Colors.black),
                              ),
                              behaviorPosition: charts.BehaviorPosition.bottom,
                              titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                            ),

                            charts.ChartTitle(
                              'Exam Score',
                              titleStyleSpec: charts.TextStyleSpec(
                                color: charts.ColorUtil.fromDartColor(Colors.black),
                              ),
                              behaviorPosition: charts.BehaviorPosition.start,
                              titleOutsideJustification: charts.OutsideJustification.middleDrawArea,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Performance Statistics',
                      style: TextStyle(
                        fontSize: 22.0,
                        color: AppColors.textColor(),
                      ),
                    ),
                  ),

                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: AppColors.containerColor(),
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                child: Text(
                                  'Total Questions Attempted:',
                                  style: TextStyle(
                                    color: AppColors.textColor(),
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                              Material(
                                color: AppColors.containerColor(),
                                elevation: 15.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PieChart(
                                    chartRadius: 120,
                                    dataMap: dataMap,
                                    showChartValuesInPercentage: false,
                                    legendPosition: LegendPosition.bottom,
                                    chartValueStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                    chartType: ChartType.disc,
                                    showChartValuesOutside: false,
                                    legendStyle: TextStyle(
                                      color: AppColors.textColor(),
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.containerColor(),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    ' Average number of answers'
                                        ' got wrong or left unattempted per test:',
                                    style: TextStyle(
                                      color: AppColors.textColor(),
                                      fontSize: 25.0,
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
                                    color: AppColors.containerColor(),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Material(
                                        color: AppColors.containerColor(),
                                        elevation: 15.0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: PieChart(
                                            chartRadius: 120,
                                            dataMap: dataMap2,
                                            showChartValuesInPercentage: false,
                                            legendPosition: LegendPosition.bottom,
                                            chartValueStyle: TextStyle(
                                              color: AppColors.textColor(),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                            ),
                                            chartType: ChartType.ring,
                                            showChartValuesOutside: false,
                                            legendStyle: TextStyle(
                                              color: AppColors.textColor(),
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        color: AppColors.containerColor(),
                      ),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'Average Test Accuracy:',
                              style: TextStyle(
                                fontSize: 28.0,
                                color: AppColors.textColor(),
                              ),
                            ),
                          ),
                          Material(
                            color: AppColors.containerColor(),
                            elevation: 10.0,
                            child: CircularPercentIndicator(
                              radius: 140,
                              lineWidth: 15,
                              progressColor: Colors.lightGreenAccent,
                              percent: avgTestAccuracy,
                              center: Text(
                                (avgTestAccuracy*100).round().toString() + "%",
                                style: TextStyle(
                                    color: AppColors.textColor(),
                                    fontSize: 35.0
                                ),
                              ),
                              circularStrokeCap: CircularStrokeCap.round,
                              backgroundColor: Colors.grey[800],
                              animation: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  radioButton(String text)
  {
    return Row(
       children: <Widget>[
         Radio(
           value: text,
           groupValue: test,
           activeColor: Colors.blueAccent,
           onChanged: (value){
             setState(() {
               test = value;
               value = test;
             });
           },
         ),
         Text(
           text,
           style: TextStyle(
             color: Colors.white,
             fontSize: 15.0,
           ),
         ),
       ],
    );
  }

}

class Performance {

  int testNo;
  int testScore;

  Performance({this.testNo,this.testScore});
}


