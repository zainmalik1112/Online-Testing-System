import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/MainScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth = FirebaseAuth.instance;
  bool progress = false;
  String email;
  String password;
  FirebaseUser loggedInUser;

  @override
  Widget build(BuildContext context) {
    return buildLoginScreen();
  }

  Scaffold buildLoginScreen() {
    return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: progress,
          child: Container(
            decoration: BoxDecoration(
                color: AppColors.backgroundColor(),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                      leading: GestureDetector(
                          child: Icon(
                              Icons.arrow_back,
                              size: 40,
                              color: Colors.pinkAccent
                          ),
                          onTap: (){
                            Navigator.pop(context);
                          }
                      )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:0),
                    child: Center(
                        child: Container(
                            child: Hero(
                              tag: 'logo',
                              child: Image(
                                image: AssetImage('images/Title.png'),
                                width: 160,
                                height: 140,
                              ),
                            )
                        )
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(18.0),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
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
                      ),
                      onChanged: (value){
                        email = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.0,0,18.0,18.0),
                    child: TextField(
                      cursorColor: Colors.white,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
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
                      ),
                      onChanged: (value){
                        password = value;
                      },
                    ),
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.pink,
                      child: MaterialButton(
                        minWidth: 200,
                        height: 42,
                        child: Text('Sign in',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {

                          if(email == null || email.isEmpty || password == null || password.isEmpty)
                            return;

                          setState(() {
                            progress = true;
                          });
                          try{
                            final user = await _auth.signInWithEmailAndPassword(email: email.trim()
                                , password: password);
                            if(user != null){
                              setState(() {
                                progress = false;
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainScreen(loggedIn: false)
                                )
                              );
                            }
                          }
                          catch(e){
                            showDialog(
                              context: context,
                              builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text(
                                      'An Error Ocurred!',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  content: Text(e.toString()),
                                );
                              }
                            );
                            setState(() {
                              progress = false;
                            });
                          }
                        },
                      )
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}