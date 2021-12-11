import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(),
            Text(
              "Reset your password",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "An email with the instructions to reset your password will be sent to your email address.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Form(
                    key: formState,
                    child: TextEditingField(
                      prefix: Icon(Icons.email),
                      hintText: "Enter your email",
                      controller: controller,
                      validator: (s) => EmailValidator.validate(s ?? "")
                          ? null
                          : "Invalid email address.",
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                      onPressed: () async => await resetPassword(),
                      child: const Text('Reset Password')),
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (!formState.currentState!.validate()) {
      return;
    }
    NavigationHelper.showLoader(context);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: controller.text);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "An email with instructions to reset your password has been sent to your email address!!")));
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
