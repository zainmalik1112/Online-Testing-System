import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {

  final String currentUserID;
  final String username;
  final String photoUrl;
  EditProfile({this.currentUserID,this.username,this.photoUrl});

  @override
  _EditProfileState createState() => _EditProfileState(
      currentUserID: this.currentUserID,
      username: this.username,
      photoUrl: this.photoUrl,
  );
}

class _EditProfileState extends State<EditProfile> {

  var newProfilePic;
  TextEditingController controller;
  final String currentUserID;
  String photoUrl;
  final globalKey = GlobalKey<ScaffoldState>();
  String username;
  String updateUsername;
  bool showProgress = false;
  Firestore firestore = Firestore.instance;

  _EditProfileState({this.currentUserID,this.username,this.photoUrl});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController(text: username);
    updateUsername = username;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  updateData(String username) async
  {
    await Firestore.instance.collection('NewsFeed').where('userID', isEqualTo: currentUserID)
        .getDocuments().then((QuerySnapshot snapshot){
          for(int i = 0; i < snapshot.documents.length; i++){
            firestore.collection('NewsFeed').document(snapshot.documents[i].data['postID'])
                .updateData({
              'username': username,
            });
          }
    });
  }

  changeProfilePic()
  {
    getImage();
  }

  Future getImage() async
  {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    if(tempImage == null){
      return;
    }

    setState(() {
      newProfilePic = tempImage;
    });

    uploadImage();
  }

  uploadImage() async
  {
    setState(() {
      showProgress = true;
    });

    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
        .child('profilePic$currentUserID.jpg');

    StorageUploadTask task = firebaseStorageRef.putFile(newProfilePic);
    await task.onComplete;

    firebaseStorageRef.getDownloadURL().then((fileUrl){
      firestore.collection('UserData').document(currentUserID).updateData({
        'photoUrl': fileUrl,
      });

      firestore.collection('NewsFeed').where('userID', isEqualTo: currentUserID)
          .getDocuments().then((QuerySnapshot snapshot){
        for(int i = 0; i < snapshot.documents.length; i++){
          firestore.collection('NewsFeed').document(snapshot.documents[i].data['postID'])
              .updateData({
            'photoUrl': fileUrl,
          });
        }
      });

      setState(() {
        showProgress = false;
        photoUrl = fileUrl;
      });
    });

    globalKey.currentState.showSnackBar(new SnackBar
      (
        content: Text('Profile Pic Updated!'),
    )
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Times New Roman"
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.check,
                size: 30.0,
                color: Colors.lightGreenAccent,
              ),
            )
          )
        ],
      ),
      body: buildBody(),
    );
  }

  removePhoto()
  {
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(
            'Remove Photo!',
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),

          content: Text(
            'Are you sure you want to remove profile pic?',
          ),

          actions: <Widget>[
            FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 18,
                ),
              ),

              onPressed: () async{
                setState(() {
                  showProgress = true;
                });
                await firestore.collection('UserData').document(currentUserID).updateData({
                  'photoUrl': "",
                });

                await firestore.collection('NewsFeed').where('userID', isEqualTo: currentUserID)
                .getDocuments().then((QuerySnapshot snapshot){
                  for(int i = 0; i < snapshot.documents.length; i++){
                    firestore.collection('NewsFeed').document(snapshot.documents[i].data['postID'])
                        .updateData({
                      'photoUrl': '',
                    });
                  }
                });
                setState(() {
                  showProgress = false;
                });
                photoUrl = '';
                Navigator.of(context).pop();
              },
            ),

            FlatButton(
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),

              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      }
    );
  }


  buildBody()
  {
    return ModalProgressHUD(
      inAsyncCall: showProgress,
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            buildContainer(),
          ],
        )
      ),
    );
  }

  buildContainer()
  {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        color: AppColors.containerColor(),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: photoUrl.isEmpty ? Hero(
                tag: 'Profile',
                child: CircleAvatar(
                  child: Text(
                    username.substring(0,1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 60.0,
                      color: Colors.white,
                    ),
                  ),
                  radius: 50.0,
                  backgroundColor: Colors.deepOrange,
                ),
              ): Hero(
                tag: 'Profile',
                child: Stack(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Colors.deepOrange,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                    Positioned(
                      left: 75,
                      child: GestureDetector(
                        child: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 25,
                        ),
                        onTap: removePhoto,
                      ),
                    )
                  ],
                ),
              )
            ),
            GestureDetector(
              child: Text(
                  photoUrl.isEmpty ? 'Add photo +': 'Change photo +',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15.0,
                ),
              ),
              onTap: changeProfilePic,
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  buildUsernameField(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: MaterialButton(
                    child: Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        )
                    ),
                    color: Colors.pink,
                    onPressed: (){
                      if(updateUsername == null || updateUsername.isEmpty){
                        showDialog(
                            context: context,
                          builder: (BuildContext context){
                              return AlertDialog(
                                title: Text(
                                    'Empty Username!',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                content: Text('Username cannot be empty!'),
                              );
                          }
                        );
                      }
                      else{
                        firestore.collection('UserData').document(currentUserID).updateData({
                          'username' : updateUsername,
                        });

                        setState(() {
                          showProgress = true;
                        });

                        updateData(updateUsername);

                        setState(() {
                          showProgress = false;
                        });

                        setState(() {
                          username = updateUsername;
                        });
                        globalKey.currentState.showSnackBar(SnackBar(
                          content: Text('Profile successfully updated!'),
                        ));
                      }
                    },
                  ),
                )
                ],
              )
            ),

          ],
        )
      ),
    );
  }

  Column buildUsernameField()
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            'Username',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: controller,
          style: TextStyle(
            color: Colors.grey[400],
          ),
          decoration: InputDecoration(
            hintText: "Update Username",
            hintStyle: TextStyle(
              color: Colors.grey[600],
            )
          ),
          onChanged: (value){
            updateUsername = value;
          },
        )
      ],
    );
  }
}
