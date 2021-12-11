import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;
import 'package:gdsc_hackathon_project/screens/admin/main_screen.dart' as admin;
import 'package:gdsc_hackathon_project/screens/common/loading_screen.dart';
import 'package:gdsc_hackathon_project/screens/common/register_info.dart';
import 'package:gdsc_hackathon_project/screens/student/main_screen.dart'
    as student;
import 'package:provider/provider.dart';

class FetchUserType extends StatelessWidget {
  const FetchUserType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return LoadingScreen();
        }
        if (snapshot.data!.data() == null) {
          return RegisterInfo();
        }
        user.User currentUser = user.User.fromDoc(snapshot.data);
        if (currentUser.userType == UserType.Student) {
          return student.MainScreen(currentUser: currentUser);
        }

        return admin.MainScreen(currentUser: currentUser);
      },
    );
  }
}
