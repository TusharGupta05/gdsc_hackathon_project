import 'package:flutter/material.dart';

class Selector<T> with ChangeNotifier {
  T val;
  Selector(this.val);

  void update(T? val) {
    if (val != null) {
      this.val = val;
      notifyListeners();
    }
  }
}
