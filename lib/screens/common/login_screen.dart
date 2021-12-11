import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController(),
      passwordController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterLogin(
          messages: LoginMessages(
              recoverPasswordDescription:
                  "An email with the instructions to reset your password will be sent to your email."),
          userType: LoginUserType.email,
          theme: LoginTheme(
              titleStyle: const TextStyle(
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          )),
          title: "Welcome to IIITB Events",
          onSignup: (signUpData) async => await signUp(signUpData),
          onLogin: (loginData) async => await signIn(loginData),
          onRecoverPassword: (email) async => await resetPassword(email)),
    );
  }

  Future<String?> resetPassword(String email) async {
    // if (!formState.currentState!.validate()) {
    //   return;
    // }
    // NavigationHelper.showLoader(context);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "An email with instructions to reset your password has been sent to your email address!!")));
    } catch (e) {
      // Navigator.of(context).pop();
      String error = "Some error occured. ";
      if (e.runtimeType == FirebaseAuthException) {
        error += (e as FirebaseAuthException).message!;
      }
      return error;
    }
  }

  Future<String?> signUp(SignupData signupData) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: signupData.name!, password: signupData.password!);
      // Navigator.of(context).pop();
      // NavigationHelper.pop(context);
      // if (credential.user != null) {

      // ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("User registered successfully!")));
      // return;
      // }
    } catch (e) {
      // Navigator.of(context).pop();
      String error = "Some error occured. ";
      if (e.runtimeType == FirebaseAuthException) {
        error += (e as FirebaseAuthException).message!;
      }
      return error;
    }
  }

  Future<String?>? signIn(LoginData loginData) async {
    // bool result = (formState.currentState!.validate());
    // if (!result) {
    //   return;
    // }
    // NavigationHelper.showLoader(context, message: 'Please wait....');
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: loginData.name, password: loginData.password);
      // NavigationHelper.pop(context);
      // if (credential.user != null) {
      // NavigationHelper.push(context, const MainScreen());
      // return;
      // }
    } catch (e) {
      // Navigator.of(context).pop();
      String error = "Some error occured. ";
      if (e.runtimeType == FirebaseAuthException) {
        error += (e as FirebaseAuthException).message!;
      }
      return error;
    }
  }
}
