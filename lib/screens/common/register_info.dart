import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/batch.dart';
import 'package:gdsc_hackathon_project/enums/branch.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;
import 'package:gdsc_hackathon_project/providers/selector.dart' as selector;
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class RegisterInfo extends StatefulWidget {
  const RegisterInfo({Key? key}) : super(key: key);

  @override
  _RegisterInfoState createState() => _RegisterInfoState();
}

class _RegisterInfoState extends State<RegisterInfo> {
  TextEditingController nameController = TextEditingController();
  TextEditingController schNumController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();
  selector.Selector<Batch> batchSelector =
      selector.Selector<Batch>(Batch.values.first);
  selector.Selector<Branch> branchSelector =
      selector.Selector<Branch>(Branch.values.first);
  late user.User currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data != null && snapshot.data!.data() != null) {
            currentUser = user.User.fromDoc(snapshot.data!);

            nameController.text = currentUser.name;
            schNumController.text = currentUser.scholarNumber;
            batchSelector.val = currentUser.batch;
            branchSelector.val = currentUser.branch;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ChangeNotifierProvider<selector.Selector<UserType>>(
              create: (context) =>
                  selector.Selector<UserType>(UserType.Student),
              builder: (ctx, __) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Spacer(),
                    const Spacer(),
                    Text(
                      'Create Profile',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    const Spacer(),
                    Form(
                      key: formState,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Consumer<selector.Selector<UserType>>(
                                builder: (_, userTypeProvider, __) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: UserType.values.reversed
                                    .map(
                                      (e) => Row(
                                        children: [
                                          Radio(
                                              value: e,
                                              groupValue: userTypeProvider.val,
                                              onChanged: (_) =>
                                                  userTypeProvider.update(e)),
                                          Text(describeEnum(e)),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              );
                            }),
                            const SizedBox(height: 30),
                            TextEditingField(
                              prefix: const Icon(Icons.person),
                              hintText: "Enter your name",
                              controller: nameController,
                              validator: (s) => validateName(s ?? ""),
                            ),
                            const SizedBox(height: 20),
                            TextEditingField(
                              hintText: "Enter your scholar number",
                              prefix: const Icon(Icons.school),
                              controller: schNumController,
                              validator: (s) => (s ?? "").isNotEmpty
                                  ? null
                                  : "Invalid scholar number",
                            ),
                            const SizedBox(height: 20),
                            batchDropDown(),
                            const SizedBox(height: 20),
                            branchDropDown(),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                        onPressed: () async => await updateProfile(ctx),
                        child: const Text("Save profile")),
                    const Spacer(),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> updateProfile(ctx) async {
    if (!formState.currentState!.validate()) {
      return;
    }
    NavigationHelper.showLoader(context);
    currentUser = user.User(
        FirebaseAuth.instance.currentUser!.uid,
        nameController.text,
        schNumController.text,
        batchSelector.val,
        branchSelector.val,
        Provider.of<selector.Selector<UserType>>(ctx, listen: false).val);

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(currentUser.toMap());
      Navigator.of(context).pop();
      return;
    } catch (e) {
      Navigator.of(context).pop();
      String error = "";
      if (e.runtimeType == FirebaseException) {
        error = (e as FirebaseException).message!;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Some error occured. $error")));
    }
  }

  String? validateName(String s) {
    for (int i = 0; i < s.length; i++) {
      if ((s[i].compareTo('A') >= 0 && s[i].compareTo('Z') <= 0) ||
          (s[i].compareTo('a') >= 0 && s[i].compareTo('z') <= 0) ||
          s[i].compareTo(" ") == 0) {
        continue;
      }
      return "Invalid char '${s[i]}'";
    }
    return s.isNotEmpty ? null : "Name can't be empty";
  }

  Widget branchDropDown() {
    return ChangeNotifierProvider<selector.Selector<Branch>>(
        create: (_) => branchSelector,
        builder: (_, __) =>
            Consumer<selector.Selector<Branch>>(builder: (_, selector, __) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Branch>(
                      isExpanded: true,
                      value: selector.val,
                      onChanged: (b) => b != null ? selector.update(b) : null,
                      items: Branch.values
                          .map((e) => DropdownMenuItem(
                                child: Text(describeEnum(e)),
                                value: e,
                              ))
                          .toList()),
                ),
              );
            }));
  }

  Widget batchDropDown() {
    return ChangeNotifierProvider<selector.Selector<Batch>>(
        create: (_) => batchSelector,
        builder: (_, __) =>
            Consumer<selector.Selector<Batch>>(builder: (_, selector, __) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Batch>(
                      isExpanded: true,
                      value: selector.val,
                      onChanged: (b) => b != null ? selector.update(b) : null,
                      items: Batch.values
                          .map((e) => DropdownMenuItem(
                                child: Text(buildBranchTextString(e)),
                                value: e,
                              ))
                          .toList()),
                ),
              );
            }));
  }

  String buildBranchTextString(Batch e) {
    return describeEnum(e)
            .replaceRange(0, 1, describeEnum(e).substring(0, 1).toUpperCase()) +
        " Year";
  }
}
