import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/functions/helper.dart';
import 'package:gdsc_hackathon_project/models/option.dart';
import 'package:gdsc_hackathon_project/models/question.dart';

class QuestionProvider extends ChangeNotifier {
  Question question;
  QuestionProvider(this.question);
  void add() {
    question.options.add(Option(Helper.timeToString(), ''));
    notifyListeners();
  }

  void remove(String id) {
    question.options.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void toggleMandatory() {
    question.mandatory = !question.mandatory;
    notifyListeners();
  }
}
