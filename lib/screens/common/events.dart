import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/event.dart';
import 'package:gdsc_hackathon_project/widgets/event_widget.dart';

class Events extends StatelessWidget {
  const Events({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        List<DocumentSnapshot<Map<String, dynamic>>> list = snapshot.data!.docs;
        list = list.reversed.toList();
        if (list.isEmpty) {
          return const Center(
            child: Text("No events to show!"),
          );
        }

        List<Event> eventsList =
            List<Event>.generate(list.length, (i) => Event.fromDoc(list[i]));
        eventsList.sort((a, b) => a.endDate.isBefore(b.endDate) ? 0 : 1);
        return ListView.builder(
          itemCount: eventsList.length,
          itemBuilder: (_, i) => EventWidget(
            event: eventsList[i],
          ),
        );
      },
    );
  }
}
