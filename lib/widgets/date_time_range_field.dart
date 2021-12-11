import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gdsc_hackathon_project/providers/selector.dart' as selector;

class DateTimeRangePickerField extends StatelessWidget {
  const DateTimeRangePickerField({Key? key, required this.validator})
      : super(key: key);
  final String? Function(String?) validator;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Consumer<selector.Selector<DateTimeRange>>(
          builder: (_, dateTimeRangeProvider, __) {
        return TextFormField(
          validator: validator,
          readOnly: true,
          controller: TextEditingController(
            text:
                'from ${dateTimeRangeProvider.val.start.toString().substring(0, 10)} to ${dateTimeRangeProvider.val.end.toString().substring(0, 10)}',
          ),
          enabled: true,
          decoration: InputDecoration(
              labelText: 'Set start and end date',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
          onTap: () async {
            DateTimeRange? newDateTimeRange = await showDateRangePicker(
              context: context,
              initialDateRange: dateTimeRangeProvider.val,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 2000)),
            );
            dateTimeRangeProvider.update(newDateTimeRange);
          },
        );
      }),
    );
  }
}
