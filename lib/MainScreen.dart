import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fun/AggregateCalculator.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/Challenge.dart';
import 'package:fun/DiscussionPanel.dart';
import 'package:fun/EnglishDictionary.dart';
import 'package:fun/PracticePage.dart';
import 'package:fun/TestPage.dart';
import 'package:fun/Notifications.dart';
import 'package:fun/ProfilePage.dart';
import 'package:fun/TimeAttackTest.dart';
import 'package:fun/User.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fun/WelcomeScreen.dart';

class MainScreen extends StatefulWidget {

  final bool loggedIn;
  MainScreen({this.loggedIn});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final bool loggedIn;
  PageController pageController;
  int pageIndex = 0;
  FirebaseUser loggedInUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  String title = "Discuss";
  Color notification = Colors.white;
  String currentUserID;
  SharedPreferences preferences;
  _MainScreenState({this.loggedIn});

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    pageController = PageController();
    if(loggedIn == true){
       getLoggedInUser();
    }
    else
      getCurrentUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildAuthScreen();
  }

  getCurrentUser() async
  {
    var user = await auth.currentUser();
    if(user!= null){
      await checkNotifications(user.uid);
      preferences = await SharedPreferences.getInstance();
      preferences.setBool("loggedIn", true);
      preferences.setString("currentUserId", user?.uid);
      setState(() {
        loggedInUser = user;
        currentUserID = loggedInUser?.uid;
      });
    }
  }

  getLoggedInUser() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      checkNotifications(preferences.getString('currentUserID'));
      currentUserID = preferences.getString('currentUserID');
    });
  }

  checkNotifications(String id) async
  {
    await Firestore.instance.collection('Notifications').document(id).collection('Notifications')
          .where('uid', isEqualTo: id)
        .getDocuments().then((QuerySnapshot snapshot){
       for(int i = 0; i < snapshot.documents.length; i++){
         if(snapshot.documents[i].data['status'] == 'new'){
           setState(() {
             notification = Colors.blueAccent;
           });
           break;
         }
       }
    });
  }

  onPageChanged(int pageIndex)
  {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  logOut() async
  {
    try{
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool('loggedIn', false);
      await auth.signOut();
    }
    catch(e){
      showDialog(
          context: null,
        builder: (context){
            return AlertDialog(
              title: Text('Error Logging out'),
              content: Text('An unknown error occured while signing out.'),
            );
        }
      );
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => MainPage(),
    ),
        (Route<dynamic> route) => false);
  }

  Future<bool> _willPopCallback() async {
    showDialog(
        context: context,
      builder: (context){
          return AlertDialog(
            title: Text(
              'EXIT F.U.N?',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.blueAccent,
              ),
            ),
            content: Text(
              'Are you sure you want to exit the app?',
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18.0,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
      }
    );
    // await showDialog or Show add banners or whatever
    // then
    return false;// return true if the route to be popped
  }

  buildAuthScreen()
  {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          centerTitle: true,
          title: Text(
              title,
            style: TextStyle(
              fontFamily: "Times New Roman",
              color: Colors.white,
              fontSize: 26.0,
            ),
          ),
          actions: <Widget>[
            currentUserID == null ? Text('') :
                Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: notification,
                      size: 30.0,
                    ),
                    onPressed: ()
                    {
                      setState(() {
                        notification = Colors.white;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Notifications(currentUserID: currentUserID)
                        )
                      );
                    },
                  ),
                )
          ],
        ),
        drawer: Drawer(
          child: currentUserID == null ? Text('') : Container(
            color: AppColors.backgroundColor(),
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30.0),
                    ),
                    color: Colors.pink,
                  ),
                  child: FutureBuilder(
                    future: Firestore.instance.collection('UserData').document(loggedInUser?.uid).get(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if(!snapshot.hasData){
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.deepOrange,
                              radius: 40.0,
                            ),
                          ],
                        );
                      }

                      User user = User.fromDoc(snapshot.data);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          user.photoUrl.isEmpty || user.photoUrl == null ? CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.deepOrange,
                            child: Text(
                              user.username.substring(0,1).toUpperCase(),
                              style: TextStyle(
                                fontSize: 40.0,
                                color: Colors.white,
                              ),
                            ),
                          ):
                          CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.deepOrange,
                            backgroundImage: NetworkImage(user.photoUrl),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              user.username,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20.0,
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontSize: 15.0,
                              )
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),

                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 25.0,
                  ),
                  title: Text(
                    'Aggregate Calculator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),

                  onTap: (){
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AggregateCalculator()
                      )
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.access_time,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Time Attack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),

                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimeAttackTest(),
                        )
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.book,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  title: Text(
                    'English Dictionary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),

                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnglishDictionary(),
                        )
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.exit_to_app,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  title: Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),

                  onTap: (){
                    logOut();
                  },
                )
              ],
            ),
          ),
        ),

        backgroundColor: AppColors.backgroundColor(),
          body: currentUserID == null ? Center(child: CircularProgressIndicator()) : PageView(
            children: <Widget>[
              DiscussionPanel(currentUserID: currentUserID),
              PracticePage(currentUserID: currentUserID),
              TestPage(currentUserID: currentUserID),
              Challenge(currentUserID: currentUserID),
              ProfilePage(currentUserID: currentUserID)
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
          bottomNavigationBar: BottomNavyBar(
              selectedIndex: pageIndex,
              onItemSelected: (int pageIndex){

                if(pageIndex == 1){
                  setState(() {
                    title = "Practice";
                  });
                }
                else if(pageIndex == 2){
                  setState(() {
                    title = "Full-Fledge Test";
                  });
                }
                else if(pageIndex == 3){
                  setState(() {
                    title = "Challenge";
                  });
                }
                else if(pageIndex == 0){
                  setState(() {
                    title = "Discuss";
                  });
                }
                else{
                  setState(() {
                    title = "Profile";
                  });
                }

                pageController.animateToPage(
                  pageIndex,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },

              backgroundColor: Color(0xFF0A0D22),
              items: [
                BottomNavyBarItem(
                  icon:
                  Icon(
                    Icons.question_answer,
                    size: 28.0,
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey,
                  title: Text('Discuss'),
                ),

                BottomNavyBarItem(
                  icon: Icon(
                    Icons.school,
                    size: 28.0,
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey,
                  title: Text('Practice'),
                ),

                BottomNavyBarItem(
                  icon: Icon
                    (
                    Icons.grade,
                    size: 28.0,
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey,
                  title: Text('Test'),
                ),

                BottomNavyBarItem(
                  icon: Icon
                    (
                    Icons.flash_on,
                    size: 28.0,
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey,
                  title: Text('Challenge'),
                ),

                BottomNavyBarItem(
                  icon: Icon
                    (
                    Icons.account_circle,
                    size: 28.0,
                  ),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.grey,
                  title: Text('Profile'),
                ),
              ]
          )
      ),
    );
  }
}