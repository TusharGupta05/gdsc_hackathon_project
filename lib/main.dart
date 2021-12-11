import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'functions/helper.dart';
import 'screens/common/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: kDebugMode);
  await FirebaseAuth.instance.signOut();
  Helper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIITB Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          headline2: TextStyle(
              fontSize: 40, fontWeight: FontWeight.w600, color: Colors.blue),
          headline3: TextStyle(
              fontSize: 32, fontWeight: FontWeight.w600, color: Colors.blue),
          headline4: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w500, color: Colors.blue),
          headline5: TextStyle(
              fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),
          headline6: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
          bodyText1: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
          bodyText2: TextStyle(
              fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
        ),
      ),
      home: const HomePage(),
    );
  }
}
