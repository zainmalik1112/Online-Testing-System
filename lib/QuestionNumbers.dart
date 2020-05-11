import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';

class QuestionNumbers extends StatefulWidget {

  final int length;
  final int currentIndex;
  final List<String> selectedOptions;
  QuestionNumbers({this.length, this.selectedOptions, this.currentIndex});
  @override
  _QuestionNumbersState createState() => _QuestionNumbersState(
    length: this.length,
    selectedOptions: this.selectedOptions,
    currentIndex: this.currentIndex,
  );
}

class _QuestionNumbersState extends State<QuestionNumbers> {

  final int length;
  final int currentIndex;
  List<String> selectedOptions;
  int number = 0;

  _QuestionNumbersState({this.length, this.selectedOptions,this.currentIndex});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      body: buildBody(),
    );
  }

  buildBody()
  {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Go to Question Number:',
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 20.0,
              ),
            ),
          ),

          Column(
            children: buildQuestionNumber(),
          )
        ],
      ),
    );
  }

  List<Widget> buildQuestionNumber()
  {
    List<Widget> list = [];

    while(true){
      list.add(
        Row(
          children: getRows(),
        )
      );

      if(number == length)
        break;
    }
    return list;
  }

  List<Widget> getRows()
  {
    List<Widget> list = [];
    for(int i = 0; i < 4; i++){
      if(number == length)
        break;
      list.add(
        buildContainer(number+1)
      );
      number++;
    }
    return list;
  }

  buildContainer(int num)
  {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Container(
          width: 80.0,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: number == currentIndex ? BorderRadius.circular(50.0): BorderRadius.circular(12.0),
            color: getContainerColor(),
          ),
          child: Center(
            child: Text(
              (number+1).toString(),
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 25.0,
              ),
            ),
          ),
        ),
        onTap: () => Navigator.pop(context, num)
      ),
    );
  }

  getContainerColor()
  {
    if(selectedOptions[number] == null && number != currentIndex)
      return AppColors.containerColor();
    else if(selectedOptions[number] == null && number == currentIndex)
      return Colors.blueAccent;
    else if(selectedOptions[number] != null)
      return Colors.green;
  }
}
