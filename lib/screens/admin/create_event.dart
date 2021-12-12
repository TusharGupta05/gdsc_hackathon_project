import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/media_type.dart';
import 'package:gdsc_hackathon_project/functions/helper.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/event.dart';
import 'package:gdsc_hackathon_project/models/media.dart';
import 'package:gdsc_hackathon_project/providers/media_list_provider.dart';
import 'package:gdsc_hackathon_project/widgets/date_time_range_field.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:gdsc_hackathon_project/providers/selector.dart' as selector;

class CreateEvent extends StatefulWidget {
  const CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Media> mediaList = [];
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaList<PlatformFile>([])),
        ChangeNotifierProvider<selector.Selector<DateTimeRange>>(
            create: (_) => selector.Selector<DateTimeRange>(DateTimeRange(
                start: DateTime.now(),
                end: DateTime.now().add(const Duration(days: 2))))),
      ],
      builder: (_, __) {
        return Builder(
          builder: (context) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('Create an event'),
                actions: [
                  IconButton(
                      onPressed: () async => await addEvent(context),
                      icon: const Icon(Icons.done))
                ],
              ),
              body: Scrollbar(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Form(
                            key: formState,
                            child: DateTimeRangePickerField(
                                validator: (_) => null)),
                        const SizedBox(height: 20),
                        TextEditingField(
                          hintText: "Title*",
                          controller: titleController,
                          maxLines: null,
                          borderRadius: 15,
                        ),
                        const SizedBox(height: 20),
                        TextEditingField(
                          hintText: "Description*",
                          controller: descriptionController,
                          borderRadius: 15,
                          maxLines: null,
                          minLines: 8,
                        ),
                        // const Spacer(),
                        const SizedBox(height: 20),
                        const Align(
                            alignment: Alignment.bottomCenter,
                            child: _MediaPreview()),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> addEvent(BuildContext ctx) async {
    if (!formState.currentState!.validate()) {
      return;
    }
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      return;
    }
    try {
      final List<PlatformFile> files =
          Provider.of<MediaList<PlatformFile>>(ctx, listen: false).mediaList;
      String id = Helper.timeToString();
      List<Reference> refs = files
          .map((e) =>
              FirebaseStorage.instance.ref('events').child(id).child(e.name))
          .toList();
      NavigationHelper.showLoader(context, message: "Uploading Files....");
      List<UploadTask> list = files
          .map((e) => FirebaseStorage.instance
              .ref('events')
              .child(id)
              .child(e.name)
              .putData(e.bytes!))
          .toList();
      await Future.wait(list);
      List<String> urls =
          await Future.wait(refs.map((e) async => e.getDownloadURL()).toList());
      DateTimeRange dateTimeRange =
          Provider.of<selector.Selector<DateTimeRange>>(ctx, listen: false).val;
      NavigationHelper.pop(context);
      NavigationHelper.showLoader(context, message: "Creating Event....");
      Event event = Event(
        Helper.timeToString(),
        titleController.text,
        descriptionController.text,
        dateTimeRange.start,
        dateTimeRange.end,
        List<Media>.generate(
          urls.length,
          (i) {
            final MediaType mediaType;
            final PlatformFile pfile = files[i];
            if (pfile.name.isImageFileName) {
              mediaType = MediaType.Image;
            } else if (pfile.name.isVideoFileName) {
              mediaType = MediaType.Video;
            } else {
              mediaType = MediaType.Other;
            }
            return Media(mediaType, urls[i], files[i].name);
          },
        ),
      );
      await FirebaseFirestore.instance
          .collection('events')
          .doc(id)
          .set(event.toMap());
      NavigationHelper.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Event created!!")));
      NavigationHelper.pop(context);
      return;
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

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaList<PlatformFile>>(builder: (_, mediaList, __) {
      return SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: mediaList.mediaList.length + 1,
          itemBuilder: (_, i) => mediaList.mediaList.length == i
              ? Container(
                  child: IconButton(
                      onPressed: () async =>
                          (await NavigationHelper.pickFiles())
                              .forEach(mediaList.add),
                      icon: const Icon(Icons.add)),
                )
              : Container(
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.center,
                          child:
                              _BuildMediaPreview(file: mediaList.mediaList[i])),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          splashRadius: 10,
                          onPressed: () {
                            mediaList.remove(i);
                          },
                          icon: const CircleAvatar(
                            radius: 10,
                            child: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 15,
                            ),
                            backgroundColor: Colors.black26,
                          ),
                        ),
                      ),
                    ],
                  ),
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 2.5,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}

class _BuildMediaPreview extends StatelessWidget {
  const _BuildMediaPreview({Key? key, required this.file}) : super(key: key);
  final PlatformFile file;
  @override
  Widget build(BuildContext context) {
    if (file.name.isImageFileName) {
      return Image.memory(file.bytes!);
    }
    // if (file.name.isVideoFileName) {
    // return Image.file(file);
    // }
    return Text(file.extension!.toUpperCase());
  }
}
