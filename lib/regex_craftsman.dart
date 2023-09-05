import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'about_dialog.dart' as been_about_dialog;

class RegexCraftsman extends StatefulWidget {
  const RegexCraftsman({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegexCraftsmanState();
  }
}

class _RegexCraftsmanState extends State<RegexCraftsman> {
  String _regex = "";
  String _testText = "";
  String _replaceWithText = "";
  String _textReplaced = "";

  List<String> _matches = [];

  int _selectedIndex = 0;

  bool multiline = true;
  bool caseSensitive = true;
  bool unicode = false;
  bool doAll = false;

  void _evaluate() {
    try {
      RegExp exp = RegExp("$_regex",
          multiLine: multiline,
          caseSensitive: caseSensitive,
          dotAll: doAll,
          unicode: unicode);
      Iterable<RegExpMatch> matches = exp.allMatches(_testText);
      setState(() {
        _matches = matches.map((e) => e[0]!).toList();
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Something went wrong when trying to parse the regex.")));
    }
  }

  _onChangedTestText(String? value) {}

  Widget _aboutDialogBuilder(BuildContext context, final String version) {
    return been_about_dialog.AboutDialog(
      applicationName: "Regex Craftsman",
      applicationSnapName: "regex_craftsman",
      applicationIcon: SizedBox(
          width: 64, height: 64, child: Image.asset("assets/images/icon.png")),
      applicationVersion: version,
      applicationLegalese: "GNU GENERAL PUBLIC LICENSE Version 3",
      applicationDeveloper: "Andrei Dodu",
    );
  }

  _loadColorizedText() {
    String markdown = _testText.replaceAll("\r\n", "").replaceAll("\n", "");
    List<Text> finalResult = [];
    try {
      if (_regex.isEmpty || markdown.isEmpty) {
        return const Text("Please fill all fields");
      }
      RegExp exp = RegExp(_regex,
          multiLine: multiline,
          caseSensitive: caseSensitive,
          dotAll: doAll,
          unicode: unicode);

      while (exp.hasMatch(markdown)) {
        var firstMatch = exp.firstMatch(markdown);
        if (firstMatch!.start != 0) {
          finalResult
              .add(_buildText(text: markdown.substring(0, firstMatch.start)));
        }
        finalResult.add(_buildText(text: firstMatch[0]!, colorized: true));
        markdown = markdown.substring(firstMatch.end);
      }
      if (markdown.isNotEmpty) {
        finalResult
            .add(_buildText(text: markdown.substring(0, markdown.length)));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Something went wrong when trying to render the result.")));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1, color: Theme.of(context).colorScheme.onBackground),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: finalResult,
          ),
        ),
      ),
    );
  }

  _buildText({String text = "test", colorized = false}) {
    return Text(
      text,
      style: TextStyle(color: colorized ? Colors.red : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.colorize), label: "Match"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "List"),
            BottomNavigationBarItem(
                icon: Icon(Icons.find_replace), label: "Replace"),
          ]),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/icon.png", width: 32),
            const Text("Regex Craftsman"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              PackageInfo.fromPlatform().then((value) => showDialog(
                  context: context,
                  builder: (ctx) {
                    return _aboutDialogBuilder(ctx, value.version);
                  }));
            },
            icon: const Icon(
              Icons.help,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _regex = value;
                _evaluate();
              });
            },
            decoration: InputDecoration(
              hintText: "Your regular expression",
              alignLabelWithHint: true,
              isDense: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: Icon(Icons.code),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.save),
                  ),
                  PopupMenuButton(
                      position: PopupMenuPosition.under,
                      icon: const Icon(Icons.menu),
                      itemBuilder: (BuildContext ctx) {
                        return [
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                multiline = !multiline;
                                _evaluate();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(multiline
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Multiline")
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                caseSensitive = !caseSensitive;
                                _evaluate();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(caseSensitive
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Case sensitive")
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                unicode = !unicode;
                                _evaluate();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(unicode
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Unicode")
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                doAll = !doAll;
                                _evaluate();
                              });
                            },
                            child: Row(
                              children: [
                                Icon(doAll
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text("Do all")
                              ],
                            ),
                          ),
                        ];
                      }),
                ],
              ),
              label: const Text("Regex"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                _testText = value;
                _evaluate();
              });
            },
            decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(Icons.text_fields),
                ),
                label: Text("Test text"),
                border: OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(4)))),
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(
            height: 10,
          ),
          if (_selectedIndex == 1)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2)),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: true,
                  itemCount: _matches.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(title: Text("${_matches[index]}")),
                    );
                  },
                ),
              ),
            ),
          if (_selectedIndex == 0)
            Expanded(
              child: _loadColorizedText(),
            ),
          if (_selectedIndex == 2) _printReplaceForm()
        ],
      ),
    );
  }

  Widget _printReplaceForm() {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
          height: 0,
        ),
        TextField(
          onChanged: (value) {
            if (value.isEmpty || _regex.isEmpty || _testText.isEmpty) {
              return;
            }
            setState(() {
              _textReplaced = _testText.replaceAll(RegExp(_regex!), value);
            });
          },
          decoration: const InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Icon(Icons.text_fields),
              ),
              label: Text("Replace with"),
              border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(4)))),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2)),
            child: SingleChildScrollView(
              child:
                  Container(width: double.infinity, child: Text(_textReplaced)),
            ),
          ),
        ),
      ]),
    );
  }
}
