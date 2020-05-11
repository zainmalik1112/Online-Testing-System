import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/EditProfile.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fun/User.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fun/CommentScreen.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:timeago/timeago.dart' as TimeAgo;
import 'package:fun/PerformanceTest.dart';

class ProfilePage extends StatefulWidget {

  final currentUserID;

  ProfilePage({this.currentUserID});

  @override
  _ProfilePageState createState() => _ProfilePageState(
    currentUserID: this.currentUserID
  );
}

class _ProfilePageState extends State<ProfilePage> {

  final currentUserID;
  final fireStore = Firestore.instance;
  bool progress = false;
  User user;

  _ProfilePageState({this.currentUserID});

  @override
  Widget build(BuildContext context) {
    return buildProfilePage();
  }

  buildProfilePage() {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      body: FutureBuilder(
        future: fireStore.collection('UserData').document(currentUserID).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(!snapshot.hasData)
            return SpinKitHourGlass(
              color: Colors.blueAccent,
              size: 30.0,
            );

          user = User.fromDoc(snapshot.data);

          return ModalProgressHUD(inAsyncCall: progress,child: buildBody());
      },
      )
    );
  }

  buildBody() {
    return SafeArea(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 8.0),
              child: profileContainer(),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
              child: Text(
                'Your Performance',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 23.0,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: AppColors.containerColor(),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image(
                            image: AssetImage('images/data.png'),
                            width: 150,
                            height: 150,
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'View Performance',
                            style: TextStyle(
                              fontSize: 23.0,
                              color: AppColors.textColor(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PerformanceTest(currentUserID: currentUserID)
                      )
                    );
                },

              )
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
              child: Text(
                'Challenges Performance',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 23.0,
                ),
              ),
            ),

            showChallenges(),

            Padding(
              padding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 8.0),
              child: Text(
                  'Your Posts',
                style: TextStyle(
                  color: AppColors.textColor(),
                  fontSize: 23.0,
                ),
              ),
            ),

            StreamBuilder(
              stream: fireStore.collection('NewsFeed')
              .orderBy('timestamp', descending: true).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(!snapshot.hasData) {
                  return SpinKitHourGlass(
                    color: Colors.blueAccent,
                    size: 30.0,
                  );
                }

                final userPost = snapshot.data.documents;
                List<Widget> posts = [];

                for(var post in userPost){
                  final username = post.data['username'];
                  final statement = post.data['statement'];
                  final email = post.data['email'];
                  final photoUrl = post.data['photoUrl'];
                  final id = post.data['postID'];
                  final userID = post.data['userID'];
                  final time = post.data['timestamp'];

                  if(userID == currentUserID)
                    posts.add(
                        buildQuestionContainer(username,email,statement,photoUrl,id,userID,time)
                    );
                }

                if(posts.isEmpty)
                  return Center(
                    child: Text(
                        'No posts yet',
                      style: TextStyle(
                        color: AppColors.textColor(),
                        fontSize: 20.0,
                      ),
                    ),
                  );
                else
                  return Column(
                    children: posts,
                  );
              },
            ),
          ],
        ),
    );
  }

  profileContainer() {
    String username = user.username;
    String photoUrl = user.photoUrl;

    return Container(
      color: AppColors.containerColor(),
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
      Row(
      children: <Widget>[
        photoUrl.isEmpty? Hero(
          tag: 'Profile',
          child: CircleAvatar(
          radius: 40.0,
          backgroundColor: Colors.deepOrange,
          child: Text(username.substring(0,1).toUpperCase(),
            style: TextStyle(
              fontSize: 50,
            )
          ),
      ),
        ): Hero(
          tag: 'Profile',
          child: GestureDetector(
            child: CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage(photoUrl),
            ),
            onTap: (){
              showDialog(
                  context: context,
                builder: (BuildContext context){
                    return Hero(
                      tag: 'Profile',
                      child: AlertDialog(
                        backgroundColor: Colors.grey[900],
                        content: Image(
                          image: NetworkImage(photoUrl),
                        ),
                      ),
                    );
                }
              );
            },
          ),
        ),

      SizedBox(
        width: 20.0,
      ),

      Container(
        width: 250,
        child: Text(username,
        style: TextStyle(
        fontSize: 30.0,
        color: AppColors.textColor(),
        ),
    ),
      )],
    ),

    Divider(
    color: Colors.grey[700],

    ),

    Container(
    width: 700,
    alignment: Alignment.bottomRight,
    child: MaterialButton(
    child: Text(
    "EDIT PROFILE",
    style: TextStyle(
    fontSize: 20.0,
    color: Colors.white,
    )
    ),
    color: Colors.pink,
    minWidth: 60.0,
    onPressed: (){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfile(currentUserID: currentUserID, username: username, photoUrl: photoUrl,),
        ),
      );
    },
    )
    )
    ]
    ,
    )
    );
  }

  buildQuestionContainer(String username,String email,String statement,String photoUrl,String id,String uid,Timestamp time) {

    String postID = id;

        return Padding(
          padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: AppColors.containerColor(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ListTile(
                    leading: photoUrl.isEmpty ? CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Colors.deepOrange,
                      child: Text(
                        username.substring(0,1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 35.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                        :CircleAvatar(
                      radius: 25.0,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    title: Text(
                        username,
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.textColor(),
                        )
                    ),
                    subtitle: Text(
                        email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[500],
                        )
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: AppColors.textColor(),
                        size: 25,
                      ),
                      onPressed: (){
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Text(
                                  'Delete Post',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                content: Text('Are you sure you want to delete the post?'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 18,
                                      ),
                                    ),
                                    onPressed: (){
                                      Firestore.instance.collection('NewsFeed').document(postID).delete();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text(
                                        'No',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                        )
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            }
                        );
                      },
                    ),
                  ),

                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 20.0),
                      child: Text(
                        statement,
                        style: TextStyle(
                          color: AppColors.textColor(),
                          fontSize: 20.0,
                        ),
                      )
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 20.0,bottom: 8.0,top: 2.0),
                              child: Icon(
                                Icons.calendar_today,
                                color: AppColors.textColor(),
                                size: 20,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 2.0, bottom: 8.0),
                                child: Text(TimeAgo.format(time.toDate()),
                                    style: TextStyle(
                                      color: AppColors.textColor(),
                                    )
                                )
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.only(left: 25.0, top: 2.0, bottom: 8.0),
                                  child: Icon(
                                    Icons.comment,
                                    size: 20,
                                    color: AppColors.textColor(),
                                  )
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 8.0, top: 2.0, bottom: 8.0),
                                  child: Text('comments',
                                      style: TextStyle(
                                        color: AppColors.textColor(),
                                      )
                                  )
                              ),
                            ],
                          ),
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentScreen(
                                  postID: postID,
                                  currentUserID: currentUserID,
                                  username: username,
                                  email: email,
                                  photoUrl: photoUrl,
                                  statement: statement,
                                  time: time,
                                  uid: uid,
                                  notification: false,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
          ),
        );
      }

   showChallenges()
   {
     return StreamBuilder(
       stream: Firestore.instance.collection('Challenges').document(currentUserID)
               .collection('Challenges').snapshots(),
       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
         if(!snapshot.hasData){
           return Container(
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(15.0),
               color: AppColors.containerColor(),
             ),
             width: 200,
             height: 200,
           );
         }

         final results = snapshot.data.documents;
         int won = 0;
         int lost = 0;
         int draw = 0;
         Map<String, double> dataMap = new Map();

         for(var res in results){
           final winnerID = res.data['winnerID'];

           if(winnerID == currentUserID)
             won++;
           else if(winnerID == 'draw')
             draw++;
           else
             lost++;
         }

         if(won == 0 && lost == 0 && draw == 0){
           return Center(
             child: Text(
               'NOT ENOUGH DATA',
               style: TextStyle(
                 color: AppColors.textColor(),
                 fontSize: 20.0,
               ),
             ),
           );
         }

         dataMap.putIfAbsent('Lost', ()=> lost.toDouble());
         dataMap.putIfAbsent('Won', ()=> won.toDouble());
         dataMap.putIfAbsent('Draw', ()=> draw.toDouble());

         return Padding(
           padding: EdgeInsets.all(8.0),
           child: Container(
             padding: EdgeInsets.all(8.0),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(15.0),
               color: AppColors.containerColor(),
             ),
             child: Material(
               color: AppColors.containerColor(),
               elevation: 25.0,
               borderRadius: BorderRadius.circular(15.0),
               child: Padding(
                 padding: EdgeInsets.all(8.0),
                 child: PieChart(
                   dataMap: dataMap,
                   chartRadius: 120,
                   showChartValuesInPercentage: false,
                   legendPosition: LegendPosition.right,
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
                   colorList: [Colors.blueGrey, Colors.lightGreenAccent,Colors.grey],
                 ),
               )
             ),
           ),
         );
       },
     );
   }
}