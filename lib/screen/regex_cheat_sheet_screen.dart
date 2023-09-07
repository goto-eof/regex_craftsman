import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegexCheatSheetScreen extends StatelessWidget {
  const RegexCheatSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Regular Expression Cheat Sheet"),
      ),
      body: ListView(padding: const EdgeInsets.all(28.0), children: [
        _title("Anchors"),
        _createListItem(
            context, "^", "matches the start of line", "^r", "room"),
        _createListItem(context, "\$", "match the end of line", "o\$", "hello"),
        // _createListItem(context, "\\A", "match the start of line", "\\Ar", "room"),
        // _createListItem(context, "\\Z", "match the end of line", "o\\Z", "hello"),
        _createListItem(
            context,
            "\\b",
            "match characters at the start or at the end of a word",
            "\\bFox\\b",
            "The Fox is on the table"),
        _createListItem(
            context,
            "\\B",
            "matches characters in the middle of other non space characters",
            "\\Bo\\B",
            "The Fox"),
        _title("Matching types of characters"),
        _createListItem(
            context, ".", "Anything except linebreak", "h.", "hello"),
        _createListItem(context, "\\d", "match a digit", "\\d", "Hello123"),
        _createListItem(context, "\\D", "match a non-digit", "\\D", "Hello123"),
        _createListItem(
            context, "\\w", "match word", "\\wll\\w", "hello world!"),
        _createListItem(
            context, "\\W", "match a non-word", "\\W", "hello world!"),
        _createListItem(
            context, "\\s", "match whitespace", "\\s", "Hello world!"),
        _createListItem(
            context, "\\S", "match non-whitespace", "\\S", "Hello world!"),
        _createListItem(
            context,
            "\\metacharacter",
            "escape a metacharacter to match on the metacharacter",
            "\\.",
            "Hello world."),
        _title("Character classes"),
        _createListItem(
            context, "[ag]", "match several characters", "[ea]", "gray grey"),
        _createListItem(context, "[a-g]", "match a range of characters",
            "[a-e]", "this is a hello word!"),
        _createListItem(context, "[^ag]",
            "does not match several of characters", "[^eo]", "Hello word!"),
        _createListItem(context, "[\\^]",
            "Match metacharacter inside the character class", "[\\^]", "3^4"),
        _title("Repetition"),
        _createListItem(context, "*", "Match 0 or more times", "a*", "Haloa!"),
        _createListItem(context, "+", "Match 1 or more times", "a+", "Haloa!"),
        _createListItem(context, "?", "Match 0 or 1 time", "a?", "Haloa!"),
        _createListItem(context, "{m}", "Match m times", "o{2}", "Moon"),
        _createListItem(
            context, "{m,}", "Match m or more times", "o{2,}", "Mooon"),
        _createListItem(
            context, "{m,n}", "Match between m and n times", "o{2,3}", "Moon"),
        _createListItem(
            context,
            "x+?",
            "Match the minimum number of times (lazy quantifier)",
            "o+?",
            "Moon"),
        _createListItem(
            context,
            "x*?",
            "Match the minimum number of times (lazy quantifier)",
            "Mo*?",
            "Moon"),
        _title("Capturing, Alternation and Backreferences"),
        _createListItem(
            context, "(x)", "Capturing a pattern", "(en)+", "French"),
        _createListItem(context, "(?:x)", "Create a group without capturing",
            "(?:x)", "example"),
        _createListItem(context, "(?<name>x)", "Create a named capture group",
            "(?<numbers>\\d)", "Example123"),
        _createListItem(context, "(a|b)", "Match several alternative patterns",
            "(i|n)", "China"),
        _createListItem(
            context,
            "\\n",
            "Reference previous captures where n is the group index starting at 1",
            "(o+)(\\w*)\\2",
            "Hello world!"),
        _createListItem(context, "\\k<name>", "Reference named captures",
            "(?<first>.*)([world]*)\\k<first>", "Hello 12345 world!"),
        _title("Lookahead"),
        _createListItem(
            context,
            "(?=x)",
            "looks ahead next character without using it in the match",
            "k(?=ey)",
            "keyboard"),
        _createListItem(
            context,
            "(?!x)",
            "looks ahead at next character to not match on",
            "(?!l)b",
            "babble"),
        _createListItem(
            context,
            "(?<=x)",
            "looks at previous characters for a match without using those in the match",
            "(?<=b).*",
            "The keyboard is on the table"),
        _createListItem(
            context,
            "(?<!x)",
            "Looks at previous characters to not match on",
            "\\w{3}(?<!ey)rd",
            "The keyboard is on the table"),
      ]),
    );
  }

  Text _title(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 22),
    );
  }

  ListTile _createListItem(BuildContext context, String syntax,
      String description, String examplePattern, String exampleString) {
    RegExp exp = RegExp(examplePattern);
    var result = exp.allMatches(exampleString).map((e) => e[0]).join(",");
    return ListTile(
      leading: Text(
        syntax,
        style: const TextStyle(fontSize: 22),
      ),
      title: Text(description),
      subtitle: Wrap(
        direction: Axis.horizontal, //default
        alignment: WrapAlignment.start,
        children: [
          const Text("Example: "),
          const Text("("),
          Text(
            examplePattern,
            style: const TextStyle(color: Colors.green),
          ),
          const Text(", "),
          Text(
            exampleString,
            style: const TextStyle(color: Colors.purple),
          ),
          const Text(") -> ["),
          Text(
            result,
            style: const TextStyle(
              color: Colors.orange,
            ),
          ),
          const Text("]"),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              tooltip: "Copy to clipboard",
              icon: const Icon(Icons.copy),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: syntax));
              }),
          IconButton(
            tooltip: "Take",
            onPressed: () async {
              Navigator.of(context).pop(syntax);
            },
            icon: const Icon(
              Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }
}
