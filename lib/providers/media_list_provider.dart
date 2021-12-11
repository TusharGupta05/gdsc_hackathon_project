import 'package:flutter/foundation.dart';

class MediaList<T> extends ChangeNotifier {
  List<T> mediaList;
  MediaList(this.mediaList);
  void add(T media) {
    mediaList.add(media);
    notifyListeners();
  }

  void remove(i) {
    mediaList.removeAt(i);
    notifyListeners();
  }
}
