import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';

import 'option.dart';

class Question {
  String id;
  List<Option> options;
  bool mandatory;

  String question;
  QuestionType questionType;
  Question(
      this.id, this.question, this.questionType, this.mandatory, this.options);
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
        map['id'],
        map['question'],
        QuestionType.values[map['questionType']],
        map['mandatory'],
        map['options'] != null
            ? map['options']
                .map<Option>((e) => Option.fromMap(e as Map<String, dynamic>))
                .toList()
            : []);
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'questionType': questionType.index,
      'mandatory': mandatory,
      'options': options.map((e) => e.toMap()).toList()
    };
  }
}
