import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/option.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:provider/provider.dart';

class RadioButtonQuestionView extends StatelessWidget {
  final Question question;
  const RadioButtonQuestionView({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedOption(
          Provider.of<FormReply>(context, listen: false).replies[question.id] !=
                  null
              ? question.options.firstWhere((element) =>
                  element.id ==
                  Provider.of<FormReply>(context, listen: false)
                      .replies[question.id])
              : Option('', '')),
      builder: (_, __) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                      '${question.question} ${question.mandatory ? '*' : ''}'),
                ),
                Consumer<SelectedOption>(
                  builder: (_, selectedOption, __) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        question.options.length,
                        (i) => RadioListTile(
                          title: Text(question.options[i].text),
                          value: question.options[i],
                          groupValue: selectedOption.option,
                          onChanged: Provider.of<FormReply>(context,
                                          listen: false)
                                      .uid ==
                                  FirebaseAuth.instance.currentUser!.uid
                              ? (_) {
                                  // print(Provider.of<FormReply>(context,
                                  //         listen: false)
                                  //     .uid);
                                  // print(FirebaseAuth.instance.currentUser!.uid);
                                  selectedOption.update(question.options[i]);
                                  Provider.of<FormReply>(context, listen: false)
                                      .updateReply(
                                          question, question.options[i].id);
                                }
                              : null,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class SelectedOption extends ChangeNotifier {
  Option option = Option('', '');
  SelectedOption(this.option);
  void update(Option option) {
    this.option = option;
    notifyListeners();
  }
}
