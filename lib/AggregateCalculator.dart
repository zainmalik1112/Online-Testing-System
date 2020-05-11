import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun/AppColors.dart';

class AggregateCalculator extends StatefulWidget {
  @override
  _AggregateCalculatorState createState() => _AggregateCalculatorState();
}

class _AggregateCalculatorState extends State<AggregateCalculator> {

  String totalFscMarksECAT = "";
  String obtainedMarksECAT = "";
  String ecatMarks = "";
  String totalFscMarksNUST = "";
  String obtainedMarksNUST = "";
  String netMarks = "";
  String totalMatricMarksNUST = "";
  String obtainedMatricNUST = "";
  String totalFscMarksFAST = "";
  String obtainedMarksFAST = "";
  String fastMarks = "";
  String aggregate = "";
  String aggregateNust = "";
  String aggregateFast = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Aggregate Calculator',
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

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5.0, left: 2.0, right: 2.0),
              child: ecatCalculator(),
            ),

            Padding(
              padding: EdgeInsets.only(top: 5.0, left: 2.0, right: 2.0),
              child: nustCalculator(),
            ),

          Padding(
            padding: EdgeInsets.only(top: 5.0, left: 2.0, right: 2.0),
            child: fastCalculator(),
          )
        ],
      ),
    );
  }

  ecatCalculator()
  {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.containerColor(),
      ),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'UET',
              style: TextStyle(
                fontSize: 25.0,
                color: AppColors.textColor(),
              ),
            ),
          ),
      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Total Fsc marks:',
            style: TextStyle(
              color: AppColors.textColor(),
              fontSize: 20.0,
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 8.0,top: 8.0),
            width: 120,
            child: TextField(
              maxLength: 4,
              maxLengthEnforced: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
              decoration: inputDecoration(),
              onChanged: (value){
                totalFscMarksECAT = value;
              },
            ),
          )
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'Obtained marks FSc:',
            style: TextStyle(
              color: AppColors.textColor(),
              fontSize: 20.0,
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 8.0,top: 8.0),
            width: 120,
            child: TextField(
              maxLength: 4,
              maxLengthEnforced: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
              decoration: inputDecoration(),
              onChanged: (value){
                obtainedMarksECAT = value;
              },
            ),
          )
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            'ECAT obtained marks:',
            style: TextStyle(
              color: AppColors.textColor(),
              fontSize: 20.0,
            ),
          ),

          Container(
            padding: EdgeInsets.only(left: 8.0,top: 8.0),
            width: 120,
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
                ecatMarks = value;
              },
            ),
          )
        ],
      ),

      Text(
        aggregate,
        style: TextStyle(
          fontSize: 20.0,
          color: AppColors.textColor(),
        ),
      ),

      OutlineButton(
        borderSide: BorderSide.none,
        child: Text(
          'CALCULATE',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 20.0,
          ),
        ),
        onPressed: (){

          if(ecatMarks.isEmpty || ecatMarks == null || obtainedMarksECAT.isEmpty || obtainedMarksECAT == null || totalFscMarksECAT.isEmpty || totalFscMarksECAT == null)
            return;

          if(num.tryParse(totalFscMarksECAT) == 0){
            setState(() {
              aggregate = 'Cannot divide by 0';
            });
            return;
          }

          if(num.tryParse(obtainedMarksECAT) > num.tryParse(totalFscMarksECAT) || num.tryParse(ecatMarks) > 400){
            setState(() {
              aggregate = 'Obtained marks out of range';
            });
            return;
          }

          double fsc = (0.7 * (num.tryParse(obtainedMarksECAT) / num.tryParse(totalFscMarksECAT)));
          double ecat = (0.3 * (num.parse(ecatMarks))/400);
          double agg = (fsc + ecat)*100;

          setState(() {
            aggregate = 'Your aggregate is $agg %';
          });
        },
      )
        ],
      ),
    );
  }

  nustCalculator()
  {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.containerColor(),
      ),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'NUST',
              style: TextStyle(
                fontSize: 25.0,
                color: AppColors.textColor(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Total FSc Part-1 marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    totalFscMarksNUST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Obtained marks FSc P-1:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    obtainedMarksNUST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Total Matric marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    totalMatricMarksNUST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Obtained Matric marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    obtainedMatricNUST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'NET Obtained marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
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
                    netMarks = value;
                  },
                ),
              )
            ],
          ),

          Text(
            aggregateNust,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor(),
            ),
          ),

          OutlineButton(
            borderSide: BorderSide.none,
            child: Text(
              'CALCULATE',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 20.0,
              ),
            ),
            onPressed: (){

              if(netMarks.isEmpty || netMarks == null || obtainedMarksNUST.isEmpty || obtainedMarksNUST == null || totalFscMarksNUST.isEmpty || totalFscMarksNUST == null
              || totalMatricMarksNUST.isEmpty || totalMatricMarksNUST == null || obtainedMatricNUST.isEmpty || obtainedMatricNUST == null)
                return;

              if(num.tryParse(totalFscMarksNUST) == 0 || num.tryParse(totalMatricMarksNUST) == 0){
                setState(() {
                  aggregateNust = 'Cannot divide by 0';
                });
                return;
              }

              if(num.tryParse(obtainedMarksNUST) > num.tryParse(totalFscMarksNUST)){
                setState(() {
                  aggregateNust = 'Obtained marks out of range';
                });
                return;
              }

              if(num.tryParse(obtainedMatricNUST) > num.tryParse(totalMatricMarksNUST)){
                setState(() {
                  aggregateNust = 'Obtained marks out of range';
                });
                return;
              }

              if(num.tryParse(netMarks) > 200){
                setState(() {
                  aggregateNust = 'Obtained marks out of range';
                });
                return;
              }

              double fsc = (0.15 * (num.tryParse(obtainedMarksNUST) / num.tryParse(totalFscMarksNUST)));
              double matric = (0.1 * (num.tryParse(obtainedMatricNUST))/num.tryParse(totalMatricMarksNUST));
              double net = (0.75 * (num.tryParse(netMarks))/200);
              double agg = (fsc + matric + net)*100;

              setState(() {
                aggregateNust = 'Your aggregate is $agg %';
              });
            },
          )
        ],
      ),
    );
  }

  fastCalculator()
  {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.containerColor(),
      ),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'FAST-NUCES',
              style: TextStyle(
                fontSize: 25.0,
                color: AppColors.textColor(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Total FSc Part-1 marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    totalFscMarksFAST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Obtained marks FSc P-1:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
                child: TextField(
                  maxLength: 4,
                  maxLengthEnforced: true,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[WhitelistingTextInputFormatter.digitsOnly],
                  decoration: inputDecoration(),
                  onChanged: (value){
                    obtainedMarksFAST = value;
                  },
                ),
              )
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'FAST Obtained marks:',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 20.0,
                ),
              ),

              Container(
                padding: EdgeInsets.only(left: 8.0,top: 8.0),
                width: 120,
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
                    fastMarks = value;
                  },
                ),
              )
            ],
          ),

          Text(
            aggregateFast,
            style: TextStyle(
              fontSize: 20.0,
              color: AppColors.textColor(),
            ),
          ),

          OutlineButton(
            borderSide: BorderSide.none,
            child: Text(
              'CALCULATE',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 20.0,
              ),
            ),
            onPressed: (){

              if(fastMarks.isEmpty || fastMarks == null || obtainedMarksFAST.isEmpty || obtainedMarksFAST == null || totalFscMarksFAST.isEmpty || totalFscMarksFAST == null)
                return;

              if(num.tryParse(totalFscMarksFAST) == 0){
                setState(() {
                  aggregateFast = 'Cannot divide by zero';
                });
                return;
              }

              if(num.tryParse(obtainedMarksFAST) > num.tryParse(totalFscMarksFAST) || num.tryParse(fastMarks) > 100){
                setState(() {
                  aggregateFast = 'Obtained marks out of range';
                });
                return;
              }

              double fsc = (0.5 * (num.tryParse(obtainedMarksFAST) / num.tryParse(totalFscMarksFAST)));
              double fast = (0.5 * (num.tryParse(fastMarks))/100);
              double agg = (fsc + fast)*100;

              setState(() {
                aggregateFast = 'Your aggregate is $agg %';
              });
            },
          )
        ],
      ),
    );
  }
}
