import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CustomizedSubject.dart';

class CustomizeSubject extends StatefulWidget {

  final int totalLength;
  final List<CustomizedSubject> subjects;

  CustomizeSubject({this.totalLength, this.subjects});

  @override
  _CustomizeSubjectState createState() => _CustomizeSubjectState(
    totalLength: this.totalLength,
    subjects: this.subjects,
  );
}

class _CustomizeSubjectState extends State<CustomizeSubject> {

  final int totalLength;
  final List<CustomizedSubject> subjects;
  String subjectValue;
  String bankValue;
  String easy = "";
  String normal = "";
  String hard = "";
  String total = "";

  _CustomizeSubjectState({this.totalLength,this.subjects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Add Subject',
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

  check5validity()
  {
    if(num.tryParse(total) < 5)
      return false;
    else
      return true;
  }

  checkTotalQuestionsValidity()
  {
    int currentLength = 0;
    for(int i = 0; i < subjects.length; i++){
      currentLength = currentLength + subjects[i].totalQuestions;
    }
    currentLength = currentLength + num.tryParse(total);

    if(currentLength > totalLength){
      return false;
    }
    else
      return true;
  }

  checkPercentageValidity()
  {
    if(num.tryParse(easy) + num.tryParse(normal) + num.tryParse(hard) == 100)
      return true;
    else
      return false;
  }

  checkRangeValidity()
  {
    if(num.tryParse(easy) < 5 || num.tryParse(easy) > 100)
      return false;
    else if(num.tryParse(normal) < 5 || num.tryParse(normal) > 100)
      return false;
    else if(num.tryParse(hard) < 5 && num.tryParse(hard) > 100)
      return false;
    else
      return true;
  }

  checkUniqueness()
  {
    for(int i = 0; i < subjects.length; i++){
      if(subjects[i].subject == subjectValue)
        return false;
    }
    return true;
  }

  showErrorMessage(String message)
  {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(
            'Conditions not met properly!',
            style: TextStyle(
             color: Colors.blueAccent,
             fontSize: 25.0,
            ),
          ),
          content: Text(message),
        );
      }
    );
  }

  addSubject()
  {
    if(easy.isEmpty || normal.isEmpty || hard.isEmpty || total.isEmpty || subjectValue == null || bankValue == null)
      return;

     bool percentageValidity = checkPercentageValidity();
     bool totalQuestionValidity = checkTotalQuestionsValidity();
     bool rangeValidity = checkRangeValidity();
     bool uniqueValidity = checkUniqueness();

     if(!percentageValidity){
       showErrorMessage('Sum of percentage of easy, normal and hard must be 100');
       return;
     }

     if(!totalQuestionValidity){
       showErrorMessage(
           'Total Questions are exceeding the total length of test provided at beginning '
               'which is $totalLength');
       return;
     }

     if(!check5validity()){
       showErrorMessage(
         'The Total Questions must be equal to or more than 5.'
       );
       return;
     }

     if(!rangeValidity){
       showErrorMessage('Range of percentage must be between 5 and 100');
       return;
     }

     if(!uniqueValidity){
       showErrorMessage('This subject is already added. Duplicate Subjects are not allowed');
       return;
     }

     int easyQuestion = convert(num.tryParse(easy));
     int normalQuestion = convert(num.tryParse(normal));
     int hardQuestion = convert(num.tryParse(hard));
     int totalQuestion = num.tryParse(total);

     while(easyQuestion + normalQuestion + hardQuestion < totalQuestion){
       hardQuestion++;
     }

     while(easyQuestion + normalQuestion + hardQuestion > totalQuestion){
       hardQuestion--;
     }

     CustomizedSubject theSubject = CustomizedSubject(
       easyQuestions: easyQuestion,
       normalQuestions: normalQuestion,
       hardQuestions: hardQuestion,
       totalQuestions: totalQuestion,
       test: bankValue,
       subject: subjectValue,
     );

     Navigator.pop(context, theSubject);
  }

  convert(int converted)
  {
    double integer = (converted/100)*(num.tryParse(total));
    int roundedInteger = integer.round();
    return roundedInteger;
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
          subjectContainer(),
          questionBankContainer(),
          detailsContainer(),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.pink,
              child: MaterialButton(
                child: Text(
                  'ADD SUBJECT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: (){
                   addSubject();
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  subjectContainer()
  {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.containerColor(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              'SUBJECT',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 25.0,
              ),
            ),
          ),
          radioButton('Chemistry'),
          radioButton('Physics'),
          radioButton('English'),
          radioButton('Computer Science'),
          radioButton('Mathematics'),
        ],
      ),
    );
  }


  questionBankContainer()
  {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.containerColor(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Text(
              'QUESTION BANK',
              style: TextStyle(
                color: Colors.pink,
                fontSize: 25.0,
              ),
            ),
          ),
          Column(
            children: getBanks(),
          )
        ],
      ),
    );
  }

  detailsContainer()
  {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.containerColor(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text(
                'ENTER DETAILS',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 25.0,
                ),
              ),
            ),
          ),
          totalNumberOfQuestions(),
          percentageEasy(),
          percentageNormal(),
          percentageHard(),
        ],
      ),
    );
  }

  totalNumberOfQuestions()
  {
    return Column(
      children: <Widget>[
        Text(
            'Total number of Questions (must be equal to or more than 5):',
          style: TextStyle(
            color: AppColors.textColor(),
            fontSize: 20.0,
          ),
        ),
        SizedBox(
          height: 10.0,
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
              total = value;
            },
          ),
        )
      ],
    );
  }

  percentageEasy() {
    return Column(
      children: <Widget>[
        Text(
          'Enter percentage of easy Questions (between 5 and 100):',
          style: TextStyle(
            color: AppColors.textColor(),
            fontSize: 20.0,
          ),
        ),

        Container(
          margin: EdgeInsets.all(8.0),
          width: 80,
          child: TextField(
            maxLength: 3,
            maxLengthEnforced: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: inputDecoration(),
            onChanged: (value) {
                easy = value;
            },
          ),
        )
      ],
    );
  }

  percentageNormal() {
    return Column(
      children: <Widget>[
        Text(
          'Enter percentage of normal Questions (between 5 and 100):',
          style: TextStyle(
            color: AppColors.textColor(),
            fontSize: 20.0,
          ),
        ),

        Container(
          margin: EdgeInsets.all(8.0),
          width: 80,
          child: TextField(
            maxLength: 3,
            maxLengthEnforced: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: inputDecoration(),
            onChanged: (value) {
                normal = value;
            },
          ),
        )
      ],
    );
  }

  percentageHard() {
    return Column(
      children: <Widget>[
        Text(
          'Enter percentage of hard Questions (between 5 and 100):',
          style: TextStyle(
            color: AppColors.textColor(),
            fontSize: 20.0,
          ),
        ),

        Container(
          margin: EdgeInsets.all(8.0),
          width: 80,
          child: TextField(
            maxLength: 3,
            maxLengthEnforced: true,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: inputDecoration(),
            onChanged: (value) {
                hard = value;
            },
          ),
        )
      ],
    );
  }

  List<Widget> getBanks()
  {
    List<Widget> list = [];

    if(subjectValue == 'Computer Science' || subjectValue == 'Chemistry'){
      list.add(radioButton2('ECAT'));
      list.add(radioButton2('NET'));
      list.add(radioButton2('NTS'));
    }
    else{
      list.add(radioButton2('ECAT'));
      list.add(radioButton2('NET'));
      list.add(radioButton2('FAST-NU'));
      list.add(radioButton2('NTS'));
    }

    return list;
  }

  radioButton(String text)
  {
    return ListTile(
      leading: Radio(
        activeColor: Colors.blueAccent,
        value: text,
        groupValue: subjectValue,
        onChanged: (value){
          setState(() {
            subjectValue = value;
            value = subjectValue;
          });
        },
      ),
      title: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor(),
          fontSize: 20.0,
        ),
      ),
    );
  }

  radioButton2(String text)
  {
    return ListTile(
      leading: Radio(
        activeColor: Colors.blueAccent,
        value: text,
        groupValue: bankValue,
        onChanged: (value){
          setState(() {
            bankValue = value;
            value = bankValue;
          });
        },
      ),
      title: Text(
        text,
        style: TextStyle(
          color: AppColors.textColor(),
          fontSize: 20.0,
        ),
      ),
    );
  }
}
