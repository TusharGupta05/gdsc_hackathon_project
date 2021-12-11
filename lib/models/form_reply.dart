import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/models/question.dart';

class FormReply {
  // List<String, dynamic> replies;
  String uid;
  Map<String, dynamic> replies = <String, dynamic>{};
  void updateReply(Question question, String reply) {
    switch (question.questionType) {
      case QuestionType.Normal:
        replies[question.id] = reply;
        break;
      case QuestionType.Checkbox:
        if (replies[question.id] == null) {
          replies[question.id] = <String>{};
        }
        if (replies[question.id].contains(reply)) {
          replies[question.id].remove(reply);
        } else {
          replies[question.id].add(reply);
        }
        break;
      case QuestionType.RadioButton:
        // if (replies[question.id] == null) {
        replies[question.id] = reply;
        // } else {
        // replies[question.id] = null;
        // }
        break;
      default:
        break;
    }
  }

  FormReply(this.uid);

  factory FormReply.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    FormReply formReply = FormReply(doc.id);
    doc.data()!.forEach(
      (key, value) {
        if (value.runtimeType != String) {
          formReply.replies[key] =
              (List.generate(value.length, (i) => value[i].toString())
                      as List<String>)
                  .toSet();
        } else {
          formReply.replies[key] = value;
        }
      },
    );
    return formReply;
  }
}
