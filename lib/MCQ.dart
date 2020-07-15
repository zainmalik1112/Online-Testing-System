import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class MCQ{

  String id;
  String statement;
  String opA, opB, opC, opD;
  String correctAnswer;
  String explanation;
  String test;
  String subject;
  String chapter;
  String difficulty;

  MCQ({
    this.id,
    this.statement,
    this.opA,
    this.opB,
    this.opC,
    this.opD,
    this.correctAnswer,
    this.explanation,
    this.test,
    this.subject,
    this.chapter,
    this.difficulty,
  });

  static void addMCQ(String test, String subject, String chapter) {
    for (int i = 0; i < 1; i++) {
      print('Hello');
      var uid = Uuid().v4();
      Firestore.instance.collection(test).document(uid).setData(({
        'statement': 'This is an easy $test question\nsubject: $subject\n chapter: $chapter\nid: $uid',
        'opA': 'This is option A',
        'opB': 'This is option B(correct)',
        'opC': 'This is option C',
        'opD': 'This is optionD',
        'correctAnswer': 'This is option B(correct)',
        'explanation': 'This is the explanation justifying the correctness of the answer.',
        'test': test,
        'subject': subject,
        'chapter': chapter,
        'difficulty': 'easy',
        'mcqID': uid,
      }));
    }

    return;

      for (int i = 0; i < 1; i++) {
        var uid = Uuid().v4();
        Firestore.instance.collection(test).document(uid).setData(({
          'statement': 'This is an normal $test question\nsubject: $subject\n chapter: $chapter\nid: $uid',
          'opA': 'This is option A',
          'opB': 'This is option B',
          'opC': 'This is option C(correct)',
          'opD': 'This is optionD',
          'correctAnswer': 'This is option C(correct)',
          'explanation': 'This is the explanation justifying the correctness of the answer.',
          'test': test,
          'subject': subject,
          'chapter': chapter,
          'difficulty': 'normal',
          'mcqID': uid,
        }));
      }

        for (int i = 0; i < 1; i++) {
          var uid = Uuid().v4();
          Firestore.instance.collection(test).document(uid).setData(({
            'statement': 'This is an hard $test question\nsubject: $subject\n chapter: $chapter\nid: $uid',
            'opA': 'This is option A',
            'opB': 'This is option B',
            'opC': 'This is option C',
            'opD': 'This is optionD(correct)',
            'correctAnswer': 'This is option D(correct)',
            'explanation': 'This is the explanation justifying the correctness of the answer.',
            'test': test,
            'subject': subject,
            'chapter': chapter,
            'difficulty': 'hard',
            'mcqID': uid,
          }));
        }
  }

  static List<MCQ> getMcq(String test, String subject, String chapter)
  {
    List<MCQ> list = [];

    for(int i = 0; i < 6; i++){
      int num = i+1;
      list.add(
        MCQ(
          id: i.toString(),
          statement: 'Question $num \n This is a question statement of $test $subject of chapter $chapter',
          opA: 'This is optionA',
          opB: 'This is optionB',
          opC: 'This is optionC',
          opD: 'This is optionD(Correct)',
          correctAnswer: 'This is optionD(Correct)',
          explanation: 'This is explanation',
          test: test,
          subject: subject,
          chapter: chapter,
          difficulty: 'Easy',
        )
      );
    }
    return list;
  }
}

