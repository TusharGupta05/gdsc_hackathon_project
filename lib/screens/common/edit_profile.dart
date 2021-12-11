import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/batch.dart';
import 'package:gdsc_hackathon_project/enums/branch.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;
import 'package:gdsc_hackathon_project/screens/common/register_screen.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController schNumController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey();
  Selector<Batch> batchSelector = Selector<Batch>(Batch.values.first);
  Selector<Branch> branchSelector = Selector<Branch>(Branch.values.first);
  late user.User currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Spacer(),
                Spacer(),
                Text(
                  'Edit your profile',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3,
                ),
                Spacer(),
                Form(
                  key: formState,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        TextEditingField(
                          prefix: Icon(Icons.person),
                          hintText: "Enter your name",
                          controller: nameController,
                          validator: (s) => validateName(s ?? ""),
                        ),
                        SizedBox(height: 20),
                        TextEditingField(
                          hintText: "Enter your scholar number",
                          prefix: Icon(Icons.school),
                          controller: schNumController,
                          validator: (s) => (s ?? "").isNotEmpty
                              ? null
                              : "Invalid scholar number",
                        ),
                        SizedBox(height: 20),
                        batchDropDown(),
                        SizedBox(height: 20),
                        branchDropDown(),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () async => await updateProfile(),
                  child: Text("Update profile"),
                ),
                Spacer(),
              ],
            ),
          );
        });
  }

  Future<void> updateProfile() async {
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
        Provider.of<user.User>(context, listen: false).userType);

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(currentUser.toMap());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile updated successfully!"),
        duration: Duration(seconds: 1),
      ));
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
    return ChangeNotifierProvider(
        create: (_) => branchSelector,
        builder: (_, __) =>
            Consumer<Selector<Branch>>(builder: (_, selector, __) {
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
    return ChangeNotifierProvider(
        create: (_) => batchSelector,
        builder: (_, __) =>
            Consumer<Selector<Batch>>(builder: (_, selector, __) {
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

class Selector<T> with ChangeNotifier {
  T val;
  Selector(this.val);

  void update(T val) {
    this.val = val;
    notifyListeners();
  }
}
