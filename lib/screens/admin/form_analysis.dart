import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/enums/question_type.dart';
import 'package:gdsc_hackathon_project/models/form.dart' as frm;
import 'package:gdsc_hackathon_project/models/form_reply.dart';
import 'package:pie_chart/pie_chart.dart';

class FormAnalysis extends StatelessWidget {
  final frm.Form form;
  const FormAnalysis({key, required this.form}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Replies Analysis'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('forms')
            .doc(form.id)
            .collection('replies')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final QuerySnapshot<Map<String, dynamic>> querySnapshot =
              snapshot.data;
          List<FormReply> formReplies =
              querySnapshot.docs.map((e) => FormReply.fromDoc(e)).toList();
          if (formReplies.isEmpty) {
            return const Center(
              child: Text('No reply received yet!'),
            );
          }
          form.questions.removeWhere(
              (element) => element.questionType == QuestionType.Normal);

          Map<String, int> cnt = <String, int>{};

          for (var formReply in formReplies) {
            formReply.replies.forEach(
              (questionId, answerId) {
                // print(value.runtimeType);
                if (answerId.runtimeType == String) {
                  cnt[answerId.toString()] =
                      (cnt[answerId.toString()] ?? 0) + 1;
                } else {
                  for (var str in answerId) {
                    cnt[str.toString()] = (cnt[str.toString()] ?? 0) + 1;
                  }
                }
              },
            );
          }
          return ListView.builder(
              // shrinkWrap: true,
              padding: const EdgeInsets.all(15),
              itemCount: form.questions.length,
              itemBuilder: (_, i) {
                // if (form.questions[i].questionType == QuestionType.Normal) {
                //   return Column(
                //     children: List.generate(form.questions[i], (index) => null),
                //   );
                // }
                return SizedBox(
                  // height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(form.questions[i].question),
                        const SizedBox(height: 30),
                        SizedBox(
                          // height: 50,
                          child: PieChart(
                            dataMap: {
                              for (int optionNumber = 1;
                                  optionNumber <=
                                      form.questions[i].options.length;
                                  optionNumber++)
                                '$optionNumber. ${form.questions[i].options[optionNumber - 1].text}':
                                    (cnt[form
                                                .questions[i]
                                                .options[optionNumber - 1]
                                                .id] ??
                                            0)
                                        .toDouble()
                            },
                            //             .toDouble(),,),
                            animationDuration:
                                const Duration(milliseconds: 800),
                            chartLegendSpacing: 32,
                            chartRadius: MediaQuery.of(context).size.width / 2,
                            // colorList: Colors.accents.sublist(0,),
                            initialAngleInDegree: 0,
                            chartType: ChartType.ring,
                            ringStrokeWidth: 32,
                            // centerText: "HYBRID",
                            legendOptions: const LegendOptions(
                              showLegendsInRow: false,
                              legendPosition: LegendPosition.bottom,
                              showLegends: true,
                              legendShape: BoxShape.circle,
                              legendTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            chartValuesOptions: const ChartValuesOptions(
                              showChartValueBackground: true,
                              showChartValues: true,
                              showChartValuesInPercentage: true,
                              showChartValuesOutside: true,
                              decimalPlaces: 2,
                            ),
                            // gradientList: ---To add gradient colors---
                            // emptyColorGradient: ---Empty Color gradient---
                          ),

                          // PieChart(
                          //   PieChartData(
                          //     sectionsSpace: 50,
                          //     centerSpaceRadius: 30,
                          //     sections: List.generate(
                          //       form.questions[i].options.length,
                          //       (index) => PieChartSectionData(
                          //         title: form.questions[i].options[index].text,
                          //         value: (cnt[form.questions[i].options[index]] ?? 0)
                          //             .toDouble(),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
