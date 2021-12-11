import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdsc_hackathon_project/models/question.dart';

class Form {
  String id;
  DateTime startDate, endDate;
  String title, description;
  List<Question> questions;
  Form(this.id, this.title, this.description, this.questions, this.startDate,
      this.endDate);
  factory Form.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Form(
      doc.id,
      doc.data()!['title'],
      doc.data()!['description'],
      (doc.data()!['questions'])
          .map<Question>((e) => Question.fromMap(e as Map<String, dynamic>))
          .toList(),
      DateTime.parse(doc.data()!['startDate']),
      DateTime.parse(doc.data()!['endDate']),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'questions': questions.map((e) => e.toMap()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
