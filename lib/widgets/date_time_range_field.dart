import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateTimeRangePickerField extends StatelessWidget {
  const DateTimeRangePickerField({Key? key, required this.validator})
      : super(key: key);
  final String? Function(String?) validator;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Consumer<DateTimeRangeProvider>(
          builder: (_, dateTimeRangeProvider, __) {
        print(dateTimeRangeProvider.dateTimeRange);
        return TextFormField(
          validator: validator,
          readOnly: true,
          controller: TextEditingController(
            text:
                'from ${dateTimeRangeProvider.dateTimeRange.start.toString().substring(0, 10)} to ${dateTimeRangeProvider.dateTimeRange.end.toString().substring(0, 10)}',
          ),
          enabled: true,
          decoration: InputDecoration(
              labelText: 'Set start and end date',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
          onTap: () async {
            DateTimeRange? newDateTimeRange = await showDateRangePicker(
              context: context,
              initialDateRange: dateTimeRangeProvider.dateTimeRange,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 2000)),
            );
            print(newDateTimeRange);
            dateTimeRangeProvider.update(newDateTimeRange);
          },
        );
      }),
    );
  }
}

class DateTimeRangeProvider extends ChangeNotifier {
  DateTimeRange dateTimeRange;
  DateTimeRangeProvider(this.dateTimeRange);
  void update(DateTimeRange? newDateTimeRange) {
    if (newDateTimeRange != null) {
      dateTimeRange = newDateTimeRange;
      notifyListeners();
    }
  }
}
