import 'package:flutter/material.dart';
import 'package:fun/ChallengeIntroduction.dart';

import 'AppColors.dart';

class ChallengeSubject extends StatefulWidget {

 final String currentUserID;
 final String challengedID;
 final String challengedUsername;
 final String challengedPhotoUrl;
 final String currentUserPhotoUrl;
 final String currentUserUsername;

 ChallengeSubject({this.currentUserID,this.challengedID,this.challengedUsername
 ,this.challengedPhotoUrl,this.currentUserUsername,this.currentUserPhotoUrl});

  @override
  _ChallengeSubjectState createState() => _ChallengeSubjectState(
    currentUserID: this.currentUserID,
    currentUserUsername: this.currentUserUsername,
    currentUserPhotoUrl: this.currentUserPhotoUrl,
    challengedPhotoUrl: this.challengedPhotoUrl,
    challengedUsername: this.challengedUsername,
    challengedID: this.challengedID,
  );
}

class _ChallengeSubjectState extends State<ChallengeSubject> {

  final String currentUserID;
  final String challengedID;
  final String challengedUsername;
  final String challengedPhotoUrl;
  final String currentUserPhotoUrl;
  final String currentUserUsername;

  _ChallengeSubjectState({this.currentUserID,this.challengedID,this.challengedUsername
    ,this.challengedPhotoUrl,this.currentUserUsername,this.currentUserPhotoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor(),
        appBar: AppBar(
          backgroundColor: Colors.pink,
          title: Text(
            'Choose Subject',
            style: TextStyle(
              fontFamily: "Times New Roman",
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
        body: SafeArea(
            child: ListView(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
                    child: Text(
                        'Choose Subject in which you want to challenge:',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: AppColors.textColor(),
                        )
                    )
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: subjects(),
                )
              ],
            )
        )
    );
  }

  List<Widget> subjects()
  {
    List<Widget> list = [];

      list.add(buildSubjectNameContainer('images/chemistry.png','Chemistry'));
      list.add(buildSubjectNameContainer('images/physics.png','Physics'));
      list.add(buildSubjectNameContainer('images/maths.png','Mathematics'));
      list.add(buildSubjectNameContainer('images/computerScience.png','Computer Science'));
      list.add(buildSubjectNameContainer('images/english.png','English'));
    return list;
  }

  buildSubjectNameContainer(String imageName, String subjectName)
  {
    return Padding(
        padding: EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: GestureDetector(
          child: Container(
              decoration: BoxDecoration(
                color: AppColors.containerColor(),
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Image(
                    image: AssetImage(imageName),
                    height: 100.0,
                  ),
                  Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                          subjectName,
                          style: TextStyle(
                            fontSize: 20.0,
                            color: AppColors.textColor(),
                          )
                      )
                  )
                ],
              )
          ),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChallengeIntroduction(
                  currentUserID: currentUserID,
                  currentUserPhotoUrl: currentUserPhotoUrl,
                  currentUserUsername: currentUserUsername,
                  challengedID: challengedID,
                  challengedPhotoUrl: challengedPhotoUrl,
                  challengedUsername: challengedUsername,
                  subject: subjectName,
                )
              ),
            );
          },
        )
    );
  }
}

