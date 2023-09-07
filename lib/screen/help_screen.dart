import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _title("Regex engine options"),
          _keyValueWidget("Multiline",
              "sets whether or not the regex matches multiple lines"),
          _keyValueWidget("Case sensitive",
              "sets whether or not the regex is case sensitive"),
          _keyValueWidget(
              "Unicode", "sets whether or not the regex is in Unicode mode"),
          _keyValueWidget("Do all",
              "sets whether or not “.” in the regex matches the line terminators."),
        ],
      ),
    );
  }

  Text _title(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22),
    );
  }

  Widget _keyValueWidget(String key, String value) {
    return Row(
      children: [
        Text(
          key,
          style: const TextStyle(color: Colors.purple),
        ),
        const SizedBox(
          width: 10,
        ),
        Text(value),
      ],
    );
  }
}
