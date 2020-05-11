import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    return true; // return true if the route to be popped
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPopCallback(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              color: AppColors.backgroundColor(),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Hero(
                          tag: 'logo',
                          child: Image(
                            image: AssetImage('images/Title.png'),
                            height: 100,
                            width: 150,
                          ),
                        ),
                      ),
                      ScaleAnimatedTextKit(
                        text: [
                          'FAST',
                          'UET',
                          'NUST',
                          'F.U.N',
                        ],

                        textStyle: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.start,
                        alignment: AlignmentDirectional.topStart,
                        duration: Duration(seconds: 1),
                        isRepeatingAnimation: true,
                        onFinished: (){
                          setState(() {
                          });
                        },
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Colors.pink,
                      elevation: 5.0,
                      child: MaterialButton(
                        minWidth: 320,
                        height: 42,

                        onPressed: (){
                          Navigator.pushNamed(context, 'LoginScreen');
                        },
                        child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white
                            )
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.0),
                    child: Material(
                        borderRadius: BorderRadius.circular(30.0),
                        color: Colors.pink,
                        elevation: 5.0,
                        child: MaterialButton(
                          minWidth: 320,
                          height: 42,
                          child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                              )
                          ),
                          onPressed: (){
                            Navigator.pushNamed(context,'RegisterScreen');
                          },
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}