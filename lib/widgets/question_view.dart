import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:gdsc_hackathon_project/widgets/normal_question.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

import 'checkbox_question_view.dart';
import 'radio_button_question_view.dart';

class QuestionView extends StatelessWidget {
  final frm.Form form;
  const QuestionView({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        form.questions.length,
        (index) {
          final Question question = form.questions[index];
          switch (question.questionType) {
            case QuestionType.RadioButton:
              return RadioButtonQuestionView(question: question);
            case QuestionType.Checkbox:
              return CheckboxQuestionView(question: question);
            default:
              return NormalQuestion(question: question);
          }
        },
      ),
    );
  }
}
