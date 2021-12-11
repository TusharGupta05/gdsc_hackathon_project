import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/functions/helper.dart';
import 'package:gdsc_hackathon_project/models/option.dart';
import 'package:gdsc_hackathon_project/models/question.dart';
import 'package:gdsc_hackathon_project/screens/admin/create_form.dart';
import 'package:gdsc_hackathon_project/widgets/text_field.dart';
import 'package:provider/provider.dart';

class QuestionView extends StatelessWidget {
  final QuestionType questionType;
  late Question question;
  QuestionView({Key? key, required this.questionType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ChangeNotifierProvider<QuestionProvider>(
        create: (_) {
          question = Question(
            Helper.timeToString(),
            '',
            questionType,
            true,
            [],
          );
          return QuestionProvider(question);
        },
        builder: (context, child) => Consumer<QuestionProvider>(
          builder: (_, questionProvider, __) {
            return Column(
              children: List.generate(
                  questionProvider.question.options.length +
                      (questionType != QuestionType.Normal ? 2 : 1), (index) {
                if (index == 0) {
                  TextEditingController questionTextController =
                      TextEditingController(
                          text: questionProvider.question.question);
                  questionTextController.addListener(() => questionProvider
                      .question.question = questionTextController.text);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: TextEditingField(
                      prefix: Checkbox(
                        value: questionProvider.question.mandatory,
                        onChanged: (_) {
                          questionProvider.toggleMandatory();
                        },
                      ),
                      controller: questionTextController,
                      hintText: '${describeEnum(questionType)} question',
                      borderRadius: 15,
                      suffix: IconButton(
                        onPressed: () {
                          Provider.of<WidgetsListProvider>(context,
                                  listen: false)
                              .remove(key!);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }
                if (index == questionProvider.question.options.length + 1) {
                  return ElevatedButton(
                    onPressed: () {
                      questionProvider.add();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.add),
                        Text('Option'),
                      ],
                    ),
                  );
                }

                TextEditingController optionTextController =
                    TextEditingController(
                        text:
                            questionProvider.question.options[index - 1].text);
                optionTextController.addListener(() {
                  questionProvider.question.options[index - 1].text =
                      optionTextController.text;
                  print(questionProvider.question.options[index - 1].text);
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: TextEditingField(
                    hintText: 'Option $index',
                    borderRadius: 15,
                    controller: optionTextController,
                    suffix: IconButton(
                      onPressed: () {
                        questionProvider.remove(
                            questionProvider.question.options[index - 1].id);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class QuestionProvider extends ChangeNotifier {
  Question question;
  QuestionProvider(this.question);
  void add() {
    question.options.add(Option(Helper.timeToString(), ''));
    notifyListeners();
  }

  void remove(String id) {
    question.options.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void toggleMandatory() {
    question.mandatory = !question.mandatory;
    notifyListeners();
  }
}
