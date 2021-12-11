import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/screens/common/fetch_user_type.dart';
import 'package:gdsc_hackathon_project/screens/common/loading_screen.dart';
import '../admin/main_screen.dart';
import 'login_screen.dart';
import '../student/main_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (_, authStateSnapshot) {
          // print(authStateSnapshot.data);
          if (authStateSnapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          }
          User? user = authStateSnapshot.data;
          // print(user);
          if (user == null) {
            return LoginScreen();
          }
          return FetchUserType();
        });
  }
}
