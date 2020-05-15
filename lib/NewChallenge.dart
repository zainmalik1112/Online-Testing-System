import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/ChallengeSubject.dart';

class NewChallenge extends StatefulWidget {

  final String currentUserID;
  NewChallenge({this.currentUserID});

  @override
  _NewChallengeState createState() => _NewChallengeState(
    currentUserID: this.currentUserID,
  );
}

class _NewChallengeState extends State<NewChallenge> {

  final String currentUserID;
  String currentUserPhotoUrl;
  String currentUserUsername;
  _NewChallengeState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'New Challenge',
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
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Challenge Anyone:',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
          StreamBuilder(
            stream: Firestore.instance.collection('UserData').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(!snapshot.hasData){
                return SpinKitRipple(
                  color: Colors.blueAccent,
                  size: 30.0,
                );
              }

              List<Widget> users = [];
              final userData = snapshot.data.documents;

              for(var data in userData){
                final username = data.data['username'];
                final uid = data.data['uid'];
                final photoUrl = data.data['photoUrl'];
                final email = data.data['email'];

                if(uid != currentUserID){
                  users.add(
                      buildUserDetail(username, uid, photoUrl, email)
                  );
                }
                else if(uid == currentUserID){
                  currentUserPhotoUrl = photoUrl;
                  currentUserUsername = username;
                }
              }

              return Container(
                color: AppColors.containerColor(),
                child: Column(
                  children: users,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  buildUserDetail(String username, String uid, String photoUrl, String email){
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: ListTile(
            leading: photoUrl.isEmpty ?
            CircleAvatar(
              backgroundColor: Colors.deepOrange,
              radius: 30.0,
              child: Text(
                username.substring(0,1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                ),
              ),
            ):
            CircleAvatar(
              backgroundImage: NetworkImage(photoUrl),
              radius: 30.0,
            ),

            title: Text(
              username,
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 24.0,
              ),
            ),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChallengeSubject(
                    currentUserID: currentUserID,
                    currentUserUsername: currentUserUsername,
                    currentUserPhotoUrl: currentUserPhotoUrl,
                    challengedID: uid,
                    challengedUsername: username,
                    challengedPhotoUrl: photoUrl,
                  )
                )
              );
            },
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
