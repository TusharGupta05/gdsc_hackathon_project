import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:gdsc_hackathon_project/models/user.dart';
import 'package:gdsc_hackathon_project/screens/admin/show_submission.dart';
import 'package:gdsc_hackathon_project/screens/student/submit_form.dart';

import 'form_analysis.dart';

class SubmissionsInfo extends StatelessWidget {
  final frm.Form form;
  const SubmissionsInfo({Key? key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submissions Info'),
        actions: [
          IconButton(
              onPressed: () {
                NavigationHelper.push(context, FormAnalysis(form: form));
              },
              icon: const Icon(Icons.bar_chart))
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('forms')
            .doc(form.id)
            .collection('replies')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot repliesSnapshot) {
          if (!repliesSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final QuerySnapshot<Map<String, dynamic>> querySnapshot =
              repliesSnapshot.data;
          List<FormReply> formReplies =
              querySnapshot.docs.map((e) => FormReply.fromDoc(e)).toList();
          if (formReplies.isEmpty) {
            return const Center(
              child: Text('No reply received yet!'),
            );
          }
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (BuildContext context, AsyncSnapshot userDataSnapshot) {
              if (!userDataSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final QuerySnapshot<Map<String, dynamic>> querySnapshot =
                  userDataSnapshot.data;
              List<User> usersList =
                  querySnapshot.docs.map<User>((e) => User.fromDoc(e)).toList();
              Map<String, User> users = {
                for (var element
                    in querySnapshot.docs.map<User>((e) => User.fromDoc(e)))
                  element.uid: element
              };
              formReplies.sort((a, b) =>
                  users[a.uid]!.userType.index > users[b.uid]!.userType.index
                      ? 1
                      : 0);
              Map<String, FormReply> formRepliesMap = {
                for (var element in formReplies) element.uid: element
              };
              return ListView.builder(
                  itemCount: formReplies.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            'Total submissions: ${formReplies.length}, Remaining submissions: ${usersList.where((element) => formReplies.contains(element) == false && element.userType == UserType.Student).toList().length - formReplies.length}',
                            maxLines: 3,
                            style: TextStyle(overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      );
                    }
                    i--;
                    return Card(
                      child: ListTile(
                        onTap: () => NavigationHelper.push(
                          context,
                          SubmitForm(
                            form: form,
                            formReply1: formReplies[i],
                          ),
                        ),
                        title: Text(
                          users[formReplies[i].uid]!.name,
                        ),
                        subtitle: Text(
                          '${users[formReplies[i].uid]!.scholarNumber}, ${describeEnum(users[formReplies[i].uid]!.branch)}, ${describeEnum(users[formReplies[i].uid]!.batch)} year',
                        ),
                        trailing: Text(
                          describeEnum(users[formReplies[i].uid]!.userType),
                          style: TextStyle(
                            fontSize: 12,
                            color: users[formReplies[i].uid]!.userType ==
                                    UserType.Admin
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  });
            },
          );
        },
      ),
    );
  }
}
