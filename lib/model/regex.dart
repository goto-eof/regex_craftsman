class Regex {
  Regex(
      {this.id,
      required this.name,
      required this.regex,
      this.testText,
      this.insertDateTime});
  int? id;
  String name;
  String regex;
  String? testText;
  DateTime? insertDateTime;

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "regex": regex,
      "test_text": testText,
      "insert_date_time": DateTime.now().toIso8601String()
    };
  }
}
