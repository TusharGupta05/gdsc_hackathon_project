import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gdsc_hackathon_project/enums/batch.dart';
import 'package:gdsc_hackathon_project/enums/branch.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';

class User {
  String uid;
  String name, scholarNumber;
  Branch branch;
  Batch batch;
  UserType userType;
  User(this.uid, this.name, this.scholarNumber, this.batch, this.branch,
      this.userType);
  factory User.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data() ?? {};
    // if (doc.data() == null) {}
    return User(
      doc.id,
      data['name'] ?? '',
      data['schNum'] ?? '',
      data['batch'] != null ? Batch.values[data['batch']] : Batch.values.first,
      data['branch'] != null
          ? Branch.values[data['branch']]
          : Branch.values.first,
      UserType.values[data['userType'] ?? 1],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'schNum': scholarNumber,
      'batch': batch.index,
      'branch': branch.index,
      'userType': userType.index,
    };
  }
}
