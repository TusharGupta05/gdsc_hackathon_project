import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(),
            Spacer(),
            Text(
              "Create Account",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formState,
                child: ChangeNotifierProvider(
                    create: (context) => UserTypeProvider(UserType.Student),
                    builder: (_, __) {
                      return Column(
                        children: [
                          TextEditingField(
                            controller: emailController,
                            prefix: Icon(Icons.email),
                            hintText: "Enter email",
                          ),
                          SizedBox(height: 20),
                          TextEditingField(
                            controller: passwordController,
                            prefix: Icon(Icons.lock),
                            hintText: "Enter password",
                            isPassword: true,
                          ),
                          SizedBox(height: 20),
                          TextEditingField(
                            controller: confirmPasswordController,
                            isPassword: true,
                            hintText: "Confirm password",
                            prefix: Icon(Icons.lock),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                              onPressed: () async => await register(),
                              child: Text('SIGN UP')),
                        ],
                      );
                    }),
              ),
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> register() async {
    if (!formState.currentState!.validate()) {
      return;
    }
    NavigationHelper.showLoader(context);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Navigator.of(context).pop();
      NavigationHelper.pop(context);
      // if (credential.user != null) {

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User registered successfully!")));
      // return;
      // }
    } catch (e) {
      Navigator.of(context).pop();
      String error = "";
      if (e.runtimeType == FirebaseAuthException) {
        error = (e as FirebaseAuthException).message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Some error occured. $error")));
    }
  }
}

class UserTypeProvider extends ChangeNotifier {
  UserType userType;
  UserTypeProvider(this.userType);
  void update(UserType userType) {
    this.userType = userType;
    notifyListeners();
  }
}
