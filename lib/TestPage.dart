import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/CustomizeTest.dart';
import 'package:fun/FieldPage.dart';

class TestPage extends StatefulWidget {

  final String currentUserID;
  TestPage({this.currentUserID});

  @override
  _TestPageState createState() => _TestPageState(currentUserID: this.currentUserID);
}

class _TestPageState extends State<TestPage> {

  final String currentUserID;
  _TestPageState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildTestPage();
  }

  Scaffold buildTestPage()
  {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            buildContainer('images/ecat.jpg','ECAT'),
            buildContainer('images/net.png','NET'),
            buildContainer('images/fast.JPG','FAST-NU'),
            buildContainer('images/customize.png', 'Customized Test'),
          ],
        ),
      ),
    );
  }

  buildContainer(String imageName, String title)
  {
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
                  width: 133,
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
         if(title == 'ECAT' || title == 'NET' || title == 'FAST-NU'){
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => FieldPage(test: title, currentUserID: currentUserID),
             ),
           );
         }
         else{
           Navigator.push(
             context,
             MaterialPageRoute(
               builder: (context) => CustomizeTest(test: title)
             )
           );
         }
        },
      ),
    );
  }
}
