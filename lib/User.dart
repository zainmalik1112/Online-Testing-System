import 'package:cloud_firestore/cloud_firestore.dart';

class User{

  final String id;
  final String username;
  final String photoUrl;
  final String email;

  User({this.id,this.username,this.email,this.photoUrl});

  factory User.fromDoc(DocumentSnapshot doc){
    return User(
      id: doc.documentID,
      username: doc['username'],
      photoUrl: doc['photoUrl'],
      email: doc['email'],
    );
  }
}