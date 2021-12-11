import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class NormalQuestion extends StatelessWidget {
  final Question question;
  const NormalQuestion({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${question.question} ${question.mandatory ? '*' : ''}'),
            TextFormField(
              enabled: Provider.of<FormReply>(context, listen: false).uid ==
                  FirebaseAuth.instance.currentUser!.uid,
              initialValue: Provider.of<FormReply>(context, listen: false)
                  .replies[question.id],
              maxLines: 2,
              minLines: 1,
              onChanged: (value) =>
                  Provider.of<FormReply>(context, listen: false)
                      .updateReply(question, value),
            )
          ],
        ),
      ),
    );
  }
}
