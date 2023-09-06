import 'package:flutter/material.dart';
import 'package:regex_craftsman/dao/regex_dao.dart';
import 'package:regex_craftsman/model/regex.dart';

class RegexFormWidget extends StatefulWidget {
  const RegexFormWidget(
      {super.key, required this.regex, required this.testText});
  final String regex;
  final String testText;

  @override
  State<StatefulWidget> createState() {
    return _RegexFormWidgetState();
  }
}

class _RegexFormWidgetState extends State<RegexFormWidget> {
  final TextEditingController _nameController = TextEditingController();
  String? validationMessage;
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void _save() async {
    print(_nameController.text);
    if (_nameController.text.isEmpty) {
      return;
    }
    RegexDao regexDao = RegexDao();
    Regex regex = Regex(
        name: _nameController.text,
        regex: widget.regex,
        testText: widget.testText);
    try {
      await regexDao.insert(regex);
      Navigator.of(context).pop();
    } catch (_) {
      setState(() {
        validationMessage =
            "A record with same name or regex value already exists";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: _save,
          child: const Text("Save"),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
                label: const Text("Name"),
                helperStyle: const TextStyle(color: Colors.red),
                helperText: validationMessage ?? ""),
            controller: _nameController,
          ),
        ],
      ),
    );
  }
}
