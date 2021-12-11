import 'package:gdsc_hackathon_project/enums/media_type.dart';

class Media {
  MediaType mediaType;
  String url, name;
  Media(this.mediaType, this.url, this.name);
  factory Media.fromMap(Map<String, dynamic> map) {
    return Media(MediaType.values[map['mediaType']], map['url'], map['name']);
  }
  Map<String, dynamic> toMap() {
    return {'mediaType': mediaType.index, 'url': url, 'name': name};
  }
}
