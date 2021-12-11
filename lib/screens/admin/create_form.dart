import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/functions/helper.dart';
import 'package:gdsc_hackathon_project/functions/navigation.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/widgets/date_time_range_field.dart';
import 'package:gdsc_hackathon_project/widgets/dynamic_radio_button_question_view.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class CreateForm extends StatefulWidget {
  const CreateForm({Key? key}) : super(key: key);

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WidgetsListProvider()),
        ChangeNotifierProvider(
            create: (_) => DateTimeRangeProvider(DateTimeRange(
                start: DateTime.now(),
                end: DateTime.now().add(Duration(days: 2)))))
      ],
      builder: (context, child) {
        return Builder(builder: (ctx) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text("Create a form"),
              actions: [
                IconButton(
                    onPressed: () async => await createForm(ctx),
                    icon: Icon(Icons.done))
              ],
            ),
            body: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Consumer2<WidgetsListProvider, DateTimeRangeProvider>(
                    builder: (_, widgetsList, __, ___) {
                      return Column(
                        children: widgetsList.widgets,
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> createForm(ctx) async {
    frm.Form? form =
        Provider.of<WidgetsListProvider>(ctx, listen: false).getForm(ctx);
    if (form == null) {
      return;
    }
    await FirebaseFirestore.instance
        .collection('forms')
        .doc(Helper.timeToString())
        .set(form.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form created successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
    NavigationHelper.pop(context);
  }
}

class WidgetsListProvider extends ChangeNotifier {
  late List<Widget> widgets;
  String title = '', description = '';
  WidgetsListProvider() {
    TextEditingController titleController = TextEditingController();
    titleController.addListener(() {
      title = titleController.text;
    });
    TextEditingController descriptionController = TextEditingController();
    descriptionController.addListener(() {
      description = descriptionController.text;
    });
    widgets = [
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: const Text(
            'Instructions:\n1. Make sure you select the checkbox of the question if you want it to be mandatory.\n2. Add Normal Question if you want the students to type their reply.\n3. Add RadioButton Questions when you want the students to be able to select exactly one option.\n4. Add Checkbox Questions when you want the students to be able to select multiple options.'),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: DateTimeRangePickerField(validator: (_) => null),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: TextEditingField(
          controller: titleController,
          hintText: 'Title',
          borderRadius: 15,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: TextEditingField(
          controller: descriptionController,
          hintText: 'Description',
          borderRadius: 15,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: ElevatedButton(
          onPressed: () {
            widgets.insert(
                widgets.length - 3,
                QuestionView(
                  key: UniqueKey(),
                  questionType: QuestionType.Normal,
                ));
            notifyListeners();
          },
          child: Row(
            children: [Icon(Icons.add), Text('Normal Question')],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: ElevatedButton(
          onPressed: () {
            widgets.insert(
                widgets.length - 3,
                QuestionView(
                  questionType: QuestionType.Checkbox,
                  key: UniqueKey(),
                ));
            notifyListeners();
          },
          child: Row(
            children: [Icon(Icons.add), Text('Checkbox Question')],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        child: ElevatedButton(
          onPressed: () {
            widgets.insert(
                widgets.length - 3,
                QuestionView(
                  questionType: QuestionType.RadioButton,
                  key: UniqueKey(),
                ));
            notifyListeners();
          },
          child: Row(
            children: [Icon(Icons.add), Text('RadioButton Question')],
          ),
        ),
      ),
    ];
  }
  void add(Widget widget) {
    widgets.insert(widgets.length - 3, widget);
    notifyListeners();
  }

  void remove(Key key) {
    widgets.removeWhere((element) => element.key == key);
    notifyListeners();
  }

  void showSnackBar(String text, ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ));
  }

  frm.Form? getForm(ctx) {
    final DateTimeRange dateTimeRange =
        Provider.of<DateTimeRangeProvider>(ctx, listen: false).dateTimeRange;
    if (title.isEmpty) {
      showSnackBar('Title should not be empty!', ctx);
      return null;
    }
    if (description.isEmpty) {
      showSnackBar('Description should not be empty!', ctx);
      return null;
    }
    frm.Form form = frm.Form(Helper.timeToString(), title, description, [],
        dateTimeRange.start, dateTimeRange.end);
    int cnt = 0;
    for (var element in widgets) {
      if (element.runtimeType == QuestionView) {
        cnt++;
        QuestionView questionView = element as QuestionView;
        if (questionView.question.question.isEmpty) {
          showSnackBar('Question should not be empty!', ctx);
          return null;
        }
        if (questionView.question.questionType != QuestionType.Normal &&
            questionView.question.options.length < 2) {
          showSnackBar(
              'Please add at least 2 options for every checkbox or radiobutton type question.',
              ctx);
          return null;
        }
        if (questionView.question.questionType != QuestionType.Normal &&
            questionView.question.options
                .any((element) => element.text.isEmpty)) {
          showSnackBar('Every option should have some text.', ctx);
          return null;
        }
        form.questions.add(questionView.question);
      }
    }
    if (cnt == 0) {
      showSnackBar('Please add at least one question!', ctx);
      return null;
    }
    return form;
  }
}
