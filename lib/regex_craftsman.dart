import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:regex_craftsman/model/regex.dart';
import 'package:regex_craftsman/screen/help_screen.dart';
import 'package:regex_craftsman/screen/regex_list_screen.dart';
import 'package:regex_craftsman/widget/regex_form_widget.dart';
import 'widget/about_dialog.dart' as been_about_dialog;

class RegexCraftsman extends StatefulWidget {
  const RegexCraftsman({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegexCraftsmanState();
  }
}

class _RegexCraftsmanState extends State<RegexCraftsman> {
  String _testText = "";
  String _textReplaced = "";

  List<String> _matches = [];
  List<Map<String, dynamic>> communityRegex = [];

  final TextEditingController _regexController = TextEditingController();
  final TextEditingController _replaceWithController = TextEditingController();

  int _selectedIndex = 0;

  List<Widget> _colorizedText = [];

  bool multiline = true;
  bool caseSensitive = true;
  bool unicode = false;
  bool doAll = false;

  @override
  void initState() {
    super.initState();
    _loadCommunityRegexFromJSON();
  }

  @override
  dispose() {
    super.dispose();
    _regexController.dispose();
    _replaceWithController.dispose();
  }

  Future<void> _loadCommunityRegexFromJSON() async {
    final String response =
        await rootBundle.loadString('assets/data/community_regex.json');
    final communityRegexData =
        List<Map<String, dynamic>>.from(await json.decode(response));
    setState(() {
      communityRegex = communityRegexData;
    });
  }

  void _evaluate() {
    try {
      RegExp exp = RegExp(_regexController.text,
          multiLine: multiline,
          caseSensitive: caseSensitive,
          dotAll: doAll,
          unicode: unicode);
      Iterable<RegExpMatch> matches = exp.allMatches(_testText);
      setState(() {
        _matches = matches.map((e) => e[0]!).toList();
      });
      _processColorizedText();
      _processReplaceWith(null);
    } catch (err) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Something went wrong when trying to parse the regex: $err")));
    }
  }

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

  _processColorizedText() {
    String testText = _testText.replaceAll("\r\n", "").replaceAll("\n", "");
    try {
      if (_regexController.text.isNotEmpty & testText.isNotEmpty) {
        setState(() {
          _colorizedText = [];
        });
        RegExp exp = RegExp(_regexController.text,
            multiLine: multiline,
            caseSensitive: caseSensitive,
            dotAll: doAll,
            unicode: unicode);
        while (exp.hasMatch(testText)) {
          var firstMatch = exp.firstMatch(testText);
          if (firstMatch!.start == firstMatch.end) {
            return;
          }
          if (firstMatch.start != 0) {
            _colorizedText.add(
                _buildMatchText(text: testText.substring(0, firstMatch.start)));
            _colorizedText.add(const SizedBox(
              width: 5,
            ));
          }
          _colorizedText
              .add(_buildMatchText(text: firstMatch[0]!, colorized: true));
          _colorizedText.add(const SizedBox(
            width: 5,
          ));

          testText = testText.substring(firstMatch.end);
        }
        if (testText.isNotEmpty) {
          _colorizedText.add(
              _buildMatchText(text: testText.substring(0, testText.length)));
          _colorizedText.add(const SizedBox(
            width: 5,
          ));
        }
        setState(() {
          _colorizedText = [..._colorizedText];
        });
      }
    } catch (err) {}
  }

  _loadColorizedText() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Match Result"),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: Theme.of(context).colorScheme.onBackground),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Wrap(
                        children: _colorizedText.isEmpty
                            ? [
                                const Text(
                                    "No data. Please fill Regex and Test text fields first.")
                              ]
                            : _colorizedText,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<int>(
                  tooltip: "Copy to clipboard",
                  icon: const Icon(Icons.copy),
                  position: PopupMenuPosition.under,
                  itemBuilder: (BuildContext ctx) {
                    return [
                      PopupMenuItem<int>(
                        onTap: () async {
                          final hightlightedText =
                              _matches.map((e) => e).toList().join(",");
                          _showCopyDoneSnackbarMessage(context);
                          await Clipboard.setData(
                              ClipboardData(text: hightlightedText));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Copy highlighted text as CSV"),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        onTap: () async {
                          final hightlightedText =
                              _matches.map((e) => e).toList();
                          _showCopyDoneSnackbarMessage(context);
                          await Clipboard.setData(ClipboardData(
                              text: jsonEncode(hightlightedText)));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Copy highlighted text as JSON"),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<int>(
                        onTap: () async {
                          final notHightlightedText = _testText
                              .split(
                                RegExp(_regexController.text,
                                    multiLine: multiline,
                                    caseSensitive: caseSensitive,
                                    dotAll: doAll,
                                    unicode: unicode),
                              )
                              .join(",");
                          _showCopyDoneSnackbarMessage(context);
                          await Clipboard.setData(
                              ClipboardData(text: notHightlightedText));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Copy not highlighted text as CSV"),
                          ],
                        ),
                      ),
                      PopupMenuItem<int>(
                        onTap: () async {
                          final notHightlightedText = _testText.split(RegExp(
                              _regexController.text,
                              multiLine: multiline,
                              caseSensitive: caseSensitive,
                              dotAll: doAll,
                              unicode: unicode));
                          _showCopyDoneSnackbarMessage(context);
                          await Clipboard.setData(ClipboardData(
                              text: jsonEncode(notHightlightedText)));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Copy not highlighted text as JSON"),
                          ],
                        ),
                      )
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildMatchText({String text = "test", colorized = false}) {
    return Text(
      text,
      style: TextStyle(
        color: colorized ? Colors.deepOrange : null,
        fontSize: colorized ? 16 : null,
      ),
    );
  }

  Widget _printReplaceForm() {
    return Expanded(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(
          height: 10,
        ),
        TextField(
          onChanged: _processReplaceWith,
          controller: _replaceWithController,
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
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text("Replace Result"),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                        width: double.infinity,
                        child: _textReplaced.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    "No data. Please fill Regex and Test text fields first."),
                              )
                            : Text(_textReplaced)),
                  ),
                ),
                PopupMenuButton(
                  tooltip: "Copy to clipboard",
                  icon: const Icon(Icons.copy),
                  position: PopupMenuPosition.under,
                  itemBuilder: (BuildContext ctx) {
                    return [
                      PopupMenuItem(
                        onTap: () async {
                          _showCopyDoneSnackbarMessage(context);
                          await Clipboard.setData(
                              ClipboardData(text: _textReplaced));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Copy to clipboard"),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _showCopyDoneSnackbarMessage(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Copied to clipboard!")));
  }

  void _processReplaceWith(_) {
    if (_regexController.text.isEmpty || _testText.isEmpty) {
      return;
    }
    setState(() {
      _textReplaced = _testText.replaceAll(
          RegExp(_regexController.text,
              multiLine: multiline,
              caseSensitive: caseSensitive,
              dotAll: doAll,
              unicode: unicode),
          _replaceWithController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            tooltip: "Highlight matched strings",
            icon: Icon(
              Icons.colorize,
              color: _selectedIndex == 0 ? Colors.deepPurple : null,
            ),
            label: "Match",
          ),
          BottomNavigationBarItem(
              tooltip: "View the list of matched strings",
              icon: Icon(
                Icons.list,
                color: _selectedIndex == 1 ? Colors.deepPurple : null,
              ),
              label: "List"),
          BottomNavigationBarItem(
              tooltip: "Replace matched string with a custom keyword",
              icon: Icon(
                Icons.find_replace,
                color: _selectedIndex == 2 ? Colors.deepPurple : null,
              ),
              label: "Replace"),
        ],
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/images/icon.png", width: 32),
            const SizedBox(
              width: 10,
            ),
            const Text("Regex Craftsman"),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              tooltip: "About this application",
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
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
                tooltip: "Regex Cheat Sheet",
                onPressed: () async {
                  String? regex =
                      await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return const HelpScreen();
                    },
                  ));
                  if (regex != null) {
                    _regexController.text = regex;
                    _evaluate();
                  }
                },
                icon: const Icon(Icons.book)),
          ),
          Container(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 10),
            child: IconButton(
              tooltip: "Your regex list",
              onPressed: () async {
                Regex? data = await Navigator.of(context).push<Regex>(
                  MaterialPageRoute(
                    builder: (context) {
                      return RegexListScreen();
                    },
                  ),
                );
                if (data != null) {
                  _regexController.text = data.regex;
                  _evaluate();
                }
              },
              icon: const Icon(
                Icons.developer_mode,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(right: 20, left: 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              onChanged: (value) {
                _evaluate();
              },
              controller: _regexController,
              decoration: InputDecoration(
                hintText: "Your regular expression",
                alignLabelWithHint: true,
                isDense: true,
                prefixIcon: PopupMenuButton(
                  tooltip: "Common Regular Expressions",
                  icon: const Icon(Icons.arrow_drop_down),
                  itemBuilder: (context) {
                    return [
                      ...communityRegex.map((e) => PopupMenuItem(
                            child: Text(
                              e["name"]!,
                            ),
                            onTap: () {
                              _regexController.text = e["regex"] as String;
                            },
                          ))
                    ];
                  },
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: "Save Regex",
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return RegexFormWidget(
                              regex: _regexController.text,
                              testText: _testText,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.save),
                    ),
                    PopupMenuButton<int>(
                        tooltip: "Regular Expression configuration and utils",
                        position: PopupMenuPosition.under,
                        icon: const Icon(Icons.menu),
                        itemBuilder: (BuildContext ctx) {
                          return [
                            PopupMenuItem<int>(
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
                            PopupMenuItem<int>(
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
                            PopupMenuItem<int>(
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
                            PopupMenuItem<int>(
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
                            const PopupMenuDivider(),
                            PopupMenuItem<int>(
                              onTap: () async {
                                _showCopyDoneSnackbarMessage(context);
                                await Clipboard.setData(
                                    ClipboardData(text: _regexController.text));
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.copy),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text("Copy to clipboard")
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
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text("List Result"),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _matches.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "No data. Please fill Regex and Test text fields first.",
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ]
                              : [
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      primary: true,
                                      itemCount: _matches.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          child: ListTile(
                                              title: Text(_matches[index])),
                                        );
                                      },
                                    ),
                                  ),
                                  PopupMenuButton<int>(
                                    tooltip: "Copy to clipboard",
                                    icon: const Icon(Icons.copy),
                                    position: PopupMenuPosition.under,
                                    itemBuilder: (BuildContext ctx) {
                                      return [
                                        PopupMenuItem<int>(
                                          onTap: () async {
                                            final hightlightedText = _matches
                                                .map((e) => e)
                                                .toList()
                                                .join(",");
                                            _showCopyDoneSnackbarMessage(
                                                context);
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: hightlightedText));
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.copy),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Copy list as CSV"),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                        PopupMenuItem<int>(
                                          onTap: () async {
                                            final hightlightedText =
                                                _matches.map((e) => e).toList();
                                            _showCopyDoneSnackbarMessage(
                                                context);
                                            await Clipboard.setData(
                                                ClipboardData(
                                                    text: jsonEncode(
                                                        hightlightedText)));
                                          },
                                          child: const Row(
                                            children: [
                                              Icon(Icons.copy),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Copy list as JSON"),
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedIndex == 0)
              Expanded(
                child: _loadColorizedText(),
              ),
            if (_selectedIndex == 2) _printReplaceForm()
          ],
        ),
      ),
    );
  }
}
