import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/screens/student/submit_form.dart';

class ShowSubmission extends StatelessWidget {
  final FormReply formReply;
  final frm.Form form;
  const ShowSubmission({Key? key, required this.formReply, required this.form})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SubmitForm(form: form);
  }
}
