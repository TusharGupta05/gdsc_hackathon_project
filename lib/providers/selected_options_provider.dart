import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/option.dart';

class SelectedOptions extends ChangeNotifier {
  Set<String> options = <String>{};
  SelectedOptions(this.options);
  void update(Option option) {
    if (options.contains(option.id)) {
      options.remove(option.id);
    } else {
      options.add(option.id);
    }
    notifyListeners();
  }
}
