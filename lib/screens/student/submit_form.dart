import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:gdsc_hackathon_project/widgets/question_view.dart';
import 'package:provider/provider.dart';

class SubmitForm extends StatelessWidget {
  const SubmitForm({Key? key, required this.form, this.formReply1})
      : super(key: key);
  final frm.Form form;
  final FormReply? formReply1;
  @override
  Widget build(BuildContext context) {
    return Provider<FormReply>(
      create: (context) =>
          formReply1 ?? FormReply(FirebaseAuth.instance.currentUser!.uid),
      builder: (_, __) {
        return Builder(builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: formReply1 != null
                      ? null
                      : () async => await submitForm(ctx),
                  icon: const Icon(
                    Icons.done,
                  ),
                ),
              ],
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  form.title,
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                const SizedBox(height: 10),
                                Text(form.description),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        QuestionView(form: form)
                      ],
                    )),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> submitForm(context) async {
    final FormReply formReply = Provider.of<FormReply>(context, listen: false);
    bool flag = true;
    for (Question question in form.questions) {
      if (question.mandatory) {
        switch (question.questionType) {
          case QuestionType.Normal:
            if ((formReply.replies[question.id] ?? '').isNotEmpty) {
              break;
            }
            flag = false;
            break;
          case QuestionType.RadioButton:
            if ((formReply.replies[question.id] ?? '').isNotEmpty) {
              break;
            }
            flag = false;
            break;
          default:
            if ((formReply.replies[question.id] ?? <String>{}).isNotEmpty) {
              break;
            }
            flag = false;
            break;
        }
      }
    }
    if (!flag) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please submit answers to all mandatory questions.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    formReply.replies.forEach((key, value) {
      if (value.runtimeType != String) {
        formReply.replies[key] = value.toList();
      }
    });
    NavigationHelper.showLoader(context, message: 'Please wait....');
    await FirebaseFirestore.instance
        .collection('forms')
        .doc(form.id)
        .collection('replies')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(formReply.replies);
    NavigationHelper.pop(context);
  }
}
