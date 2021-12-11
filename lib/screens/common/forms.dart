import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/screens/admin/submissions_info.dart';
import 'package:gdsc_hackathon_project/screens/student/submit_form.dart';
import 'package:provider/provider.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;

class Forms extends StatelessWidget {
  const Forms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('forms').snapshots(),
        builder: (BuildContext _, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          QuerySnapshot<Map<String, dynamic>> querySnapshot = snapshot.data!;
          List<DocumentSnapshot<Map<String, dynamic>>> docs =
              querySnapshot.docs;
          docs = docs.reversed.toList();
          if (docs.isEmpty) {
            return const Center(child: Text('No forms to show!'));
          }
          List<frm.Form> forms = docs.map((e) => frm.Form.fromDoc(e)).toList();

          forms.removeWhere((element) =>
              DateTime.now().isAfter(element.endDate) ||
              DateTime.now().isBefore(element.startDate));
          return ListView.builder(
            itemCount: forms.length,
            itemBuilder: (_, i) => Card(
              child: ListTile(
                onTap: () async {
                  // NavigationHelper.push(context, SubmissionsInfo(form: forms[i]));
                  var something = await FirebaseFirestore.instance
                      .collection('forms')
                      .doc(forms[i].id)
                      .collection('replies')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get();
                  if (something.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("You have already submitted the form.")));
                  } else {
                    final user.User currentUser =
                        // context.watch<user.User>();
                        Provider.of<user.User>(context, listen: false);
                    if (currentUser.userType == UserType.Student) {
                      NavigationHelper.push(
                          context, SubmitForm(form: forms[i]));
                    } else {
                      NavigationHelper.push(
                          context, SubmissionsInfo(form: forms[i]));
                    }
                  }
                  // NavigationHelper.push(context, SubmitForm(form: forms[i]));
                },
                title: Text(forms[i].title),
                subtitle: Text(
                  'Deadline: ${forms[i].endDate.toString().substring(0, 10)}',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        });
  }
}
