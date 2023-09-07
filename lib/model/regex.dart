class Regex {
  Regex(
      {this.id,
      required this.name,
      required this.regex,
      this.testText,
      this.insertDateTime})
      : this.takeTestText = false;
  int? id;
  String name;
  String regex;
  String? testText;
  DateTime? insertDateTime;
  bool takeTestText;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "regex": regex,
      "test_text": testText,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
