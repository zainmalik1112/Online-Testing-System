import 'package:flutter/material.dart';
import 'package:fun/MainScreen.dart';
import 'package:fun/WelcomeScreen.dart';
import 'package:fun/LoginScreen.dart';
import 'package:fun/RegisterScreen.dart';
import 'package:fun/Post.dart';
import 'package:fun/EditProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool loggedIn = preferences.getBool('loggedIn');

  runApp(Home(loggedIn: loggedIn));
}

class Home extends StatelessWidget {

  final bool loggedIn;
  Home({this.loggedIn});
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        body: loggedIn == true ? MainScreen(loggedIn: loggedIn): MainPage(),
      ),
      initialRoute: loggedIn == true ? 'MainScreen':'WelcomeScreen',
      routes: {
        'LoginScreen': (context) => LoginScreen(),
        'WelcomeScreen' : (context) => MainPage(),
        'RegisterScreen' : (context) => RegisterScreen(),
        'Post' : (context) => Post(),
        'EditProfile' : (context) => EditProfile(),
        'MainScreen' : (context) => MainScreen(loggedIn: loggedIn),
      },
    );
  }
}