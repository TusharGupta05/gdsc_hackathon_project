class Option {
  String id, text;
  Option(this.id, this.text);
  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(map['id'], map['text']);
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text};
  }
}
