import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/MainScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final fireStore = Firestore.instance;
  final auth = FirebaseAuth.instance;
  bool showProgess = false;
  String username;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return buildRegisterScreen();
  }

  Scaffold buildRegisterScreen() {
    return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showProgess,
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
                    padding: EdgeInsets.only(top: 0),
                    child: Container(
                        child: Hero(
                          tag: 'logo',
                          child: Image(
                            image: AssetImage('images/Title.png'),
                            width: 160,
                            height: 140,
                          ),
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
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Username',
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
                        username = value;
                      },

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.0,0,18.0,18.0),
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      cursorColor: Colors.white,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                      obscureText: true,
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
                        child: Text('Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: (){

                          if(username == null || username.isEmpty || email == null || email.isEmpty || password == null || password.isEmpty)
                            return;

                          setState(() {
                            showProgess = true;
                          });

                          try {
                            signUpUser();
                          }

                          catch(e)
                          {
                            print(e.toString());
                          }
                          setState(() {
                            showProgess = false;
                          });
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

  void signUpUser() async{

    AuthResult authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
    FirebaseUser user = authResult.user;

    if(user!=null){
      fireStore.collection('UserData').document(user.uid).setData({
        'email': email,
        'username': username,
        'photoUrl': '',
        'uid': user.uid,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen()
        )
      );
    }
  }
}