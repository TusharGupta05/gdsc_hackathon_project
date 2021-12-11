import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'media.dart';

class Event {
  String id, title, description;
  List<Media> mediaList;
  DateTime startDate, endDate;
  Event(this.id, this.title, this.description, this.startDate, this.endDate,
      this.mediaList);
  factory Event.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    print(doc.data()!);
    return Event(
      doc.id,
      doc.data()!['title'],
      doc.data()!['description'],
      DateTime.parse(doc.data()!['startDate']),
      DateTime.parse(doc.data()!['endDate']),
      // DateTime.fromMillisecondsSinceEpoch(
      //     (doc.data()!['startDate'] as Timestamp).millisecondsSinceEpoch),
      // DateTime.fromMillisecondsSinceEpoch(
      //     (doc.data()!['endDate'] as Timestamp).millisecondsSinceEpoch),
      List<Media>.generate(
        doc.data()!['mediaList'].length,
        (i) => Media.fromMap(doc.data()!['mediaList'][i]),
      ),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'mediaList': List<Map<String, dynamic>>.generate(
        mediaList.length,
        (i) => mediaList[i].toMap(),
      ),
    };
  }
}
