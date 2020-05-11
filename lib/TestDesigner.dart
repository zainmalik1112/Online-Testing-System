import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fun/MCQ.dart';
import 'dart:math' as math;

preparePracticeTest(String test, String subject, String chapter) async
{
  List<MCQ> ecat = [];
  List<MCQ> easy = [];
  List<MCQ> normal = [];
  List<MCQ> hard = [];
  List<MCQ> practiceTest = [];

  await Firestore.instance.collection(test)
      .where('test', isEqualTo: test)
      .where('subject', isEqualTo: subject)
      .where('chapter', isEqualTo: chapter)
      .getDocuments().then((QuerySnapshot snapshot){
        for(int i = 0; i < snapshot.documents.length; i++){
          ecat.add(
            MCQ(
              id: snapshot.documents[i].data['mcqID'],
              statement: snapshot.documents[i].data['statement'],
              opA: snapshot.documents[i].data['opA'],
              opB: snapshot.documents[i].data['opC'],
              opC: snapshot.documents[i].data['opD'],
              opD: snapshot.documents[i].data['opD'],
              correctAnswer: snapshot.documents[i].data['correctAnswer'],
              difficulty: snapshot.documents[i].data['difficulty'],
            )
          );
        }
  });

  for(int i = 0; i < ecat.length; i++){
    if(ecat[i].difficulty == 'easy')
      easy.add(ecat[i]);
  }

  for(int i = 0; i < ecat.length; i++){
    if(ecat[i].difficulty == 'normal')
      normal.add(ecat[i]);
  }

  for(int i = 0; i < ecat.length; i++){
    if(ecat[i].difficulty == 'easy')
      hard.add(ecat[i]);
  }

  for(int i = 0 ; i < 10; i++){
    int index;
    bool proceed = false;

    while(!proceed){
      index = math.Random.secure().nextInt(easy.length);

      if(practiceTest.contains(easy[index])){
        proceed = false;
      }
      else
        proceed = true;
    }
    practiceTest.add(easy[index]);
  }

  for(int i = 0 ; i < 15; i++){
    int index;
    bool proceed = false;

    while(!proceed){
      index = math.Random.secure().nextInt(normal.length);

      if(practiceTest.contains(normal[index])){
        proceed = false;
      }
      else
        proceed = true;
    }
    practiceTest.add(normal[index]);
  }

  for(int i = 0 ; i < 5; i++){
    int index;
    bool proceed = false;

    while(!proceed){
      index = math.Random.secure().nextInt(hard.length);

      if(practiceTest.contains(hard[index])){
        proceed = false;
      }
      else
        proceed = true;
    }
    practiceTest.add(hard[index]);
  }

  return practiceTest;
}