import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:gdsc_hackathon_project/providers/selected_options_provider.dart';
import 'package:provider/provider.dart';

class CheckboxQuestionView extends StatelessWidget {
  final Question question;
  const CheckboxQuestionView({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectedOptions(
          Provider.of<FormReply>(context, listen: false).replies[question.id] ??
              <String>{}),
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
                Consumer<SelectedOptions>(
                  builder: (_, selectedOptions, __) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        question.options.length,
                        (i) => ListTile(
                          leading: Checkbox(
                            value: selectedOptions.options
                                .contains(question.options[i].id),
                            onChanged: Provider.of<FormReply>(context,
                                            listen: false)
                                        .uid ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? (_) {
                                    selectedOptions.update(question.options[i]);
                                    Provider.of<FormReply>(context,
                                            listen: false)
                                        .updateReply(
                                            question, question.options[i].id);
                                  }
                                : null,
                          ),
                          title: Text(question.options[i].text),
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
