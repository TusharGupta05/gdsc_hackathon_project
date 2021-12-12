import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gdsc_hackathon_project/enums/user_type.dart';
import 'package:gdsc_hackathon_project/models/event.dart';
import 'package:gdsc_hackathon_project/models/user.dart';
import 'package:provider/provider.dart';

import 'media_previewer.dart';

class EventWidget extends StatelessWidget {
  final Event event;
  const EventWidget({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headline4,
                    maxLines: 10,
                  ),
                ),
                PopupMenuButton(
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (_) => [
                          PopupMenuItem(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text:
                                      '${event.title}\n${event.description}'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Text copied'),
                                duration: Duration(seconds: 1),
                              ));
                            },
                            child: const Text('Copy Text'),
                          ),
                          if (Provider.of<User>(context, listen: false)
                                  .userType ==
                              UserType.Admin)
                            PopupMenuItem(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title:
                                              const Text('Delete this event?'),
                                          content: const Text(
                                              'Are you sure want to delete this event?'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('events')
                                                      .doc(event.id)
                                                      .delete();
                                                },
                                                child: const Text('Delete')),
                                            ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Cancel')),
                                          ],
                                        ));
                                showDialog(
                                    context: _,
                                    builder: (_) => const AlertDialog());
                              },
                              child: const Text('Delete this event'),
                            ),
                        ]),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              event.description,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(
              height: 20,
            ),
            MediaPreviewer(mediaList: event.mediaList),
          ],
        ),
      ),
    );
  }
}
