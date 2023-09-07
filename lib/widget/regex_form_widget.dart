import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  var focusNode = FocusNode();
  String? validationMessage;
  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
  }

  void _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        validationMessage = "Name should not be empty";
      });
      return;
    }
    if (widget.regex.trim().isEmpty) {
      setState(() {
        validationMessage = "Regex should not be empty";
      });
      return;
    }
    RegexDao regexDao = RegexDao();
    Regex regex = Regex(
        name: _nameController.text,
        regex: widget.regex,
        testText: widget.testText);
    try {
      await regexDao.insert(regex);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Regex saved!")));
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
          RawKeyboardListener(
            focusNode: focusNode,
            onKey: (event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _save();
              }
            },
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  label: const Text("Name"),
                  helperStyle: TextStyle(
                      color: validationMessage != null
                          ? Colors.red
                          : Theme.of(context).colorScheme.onBackground),
                  helperText: validationMessage ?? "Press Enter key to save"),
              controller: _nameController,
            ),
          ),
        ],
      ),
    );
  }
}
