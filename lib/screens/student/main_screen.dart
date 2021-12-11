import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;
import '../common/edit_profile.dart';
import '../common/events.dart';
import '../common/forms.dart';
import 'package:gdsc_hackathon_project/providers/selector.dart' as selector;

class MainScreen extends StatelessWidget {
  final user.User currentUser;
  const MainScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<selector.Selector<int>>(
          create: (_) => selector.Selector<int>(0),
        ),
        Provider(create: (_) => currentUser)
      ],
      builder: (_, __) {
        return Scaffold(
          appBar: AppBar(
            leading: const SizedBox(),
            leadingWidth: 0,
            title: const Text("IIITB Events"),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: Consumer<selector.Selector<int>>(
            builder: (_, bnbItemSelector, __) {
              switch (bnbItemSelector.val) {
                case 0:
                  return const Events();
                case 1:
                  return const Forms();
                default:
                  return const EditProfile();
              }
            },
          ),
          bottomNavigationBar: Consumer<selector.Selector<int>>(
            builder: (_, bnbItemSelector, __) {
              return BottomNavigationBar(
                currentIndex: bnbItemSelector.val,
                onTap: bnbItemSelector.update,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.event), label: "Events"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.ac_unit), label: "Forms"),
                  BottomNavigationBarItem(
                      icon: Icon(CupertinoIcons.person_solid), label: "Profile")
                ],
              );
            },
          ),
        );
      },
    );
  }
}
