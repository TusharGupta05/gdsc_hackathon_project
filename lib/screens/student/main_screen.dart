import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/screens/admin/create_event.dart';
import 'package:gdsc_hackathon_project/screens/admin/create_form.dart';
import 'package:provider/provider.dart';
import 'package:gdsc_hackathon_project/models/user.dart' as user;
import '../common/edit_profile.dart';
import '../common/events.dart';
import '../common/forms.dart';

class MainScreen extends StatelessWidget {
  final user.User currentUser;
  const MainScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<BnbItemSelector>(
            create: (_) => BnbItemSelector(),
          ),
          Provider(create: (_) => currentUser)
        ],
        builder: (_, __) {
          return Scaffold(
            appBar: AppBar(
              leading: SizedBox(),
              leadingWidth: 0,
              title: Text("IIITB Events"),
              actions: [
                IconButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: Icon(Icons.logout),
                ),
              ],
            ),
            body: Consumer<BnbItemSelector>(
              builder: (_, bnbItemSelector, __) {
                switch (bnbItemSelector.index) {
                  case 0:
                    return Events();
                  case 1:
                    return const Forms();
                  default:
                    return EditProfile();
                }
              },
            ),
            bottomNavigationBar:
                Consumer<BnbItemSelector>(builder: (_, bnbItemSelector, __) {
              return BottomNavigationBar(
                  currentIndex: bnbItemSelector.index,
                  onTap: bnbItemSelector.updateIndex,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.event), label: "Events"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.ac_unit), label: "Forms"),
                    BottomNavigationBarItem(
                        icon: Icon(CupertinoIcons.person_solid),
                        label: "Profile")
                  ]);
            }),
          );
        });
  }
}

class BnbItemSelector with ChangeNotifier {
  int index = 0;
  void updateIndex(int newIndex) {
    index = newIndex;
    notifyListeners();
  }
}
