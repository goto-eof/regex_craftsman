import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:regex_craftsman/dao/regex_dao.dart';
import 'package:regex_craftsman/model/regex.dart';

class RegexListScreen extends StatefulWidget {
  const RegexListScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RegexListScreenState();
  }
}

class _RegexListScreenState extends State<RegexListScreen> {
  @override
  Widget build(BuildContext context) {
    Future<List<Regex>> _retrieveFutureData() async {
      return await RegexDao().list();
    }

    Future<int> _loadCountItems() async {
      return await RegexDao().count();
    }

    return FutureBuilder(
      future: _loadCountItems(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Your regex list (${snapshot.data!})"),
            ),
            body: FutureBuilder(
              future: _retrieveFutureData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No data"),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      return ListTile(
                        hoverColor: Theme.of(context).colorScheme.onBackground,
                        key: Key(data.name),
                        title: Text(data.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              data.regex,
                              style: const TextStyle(color: Colors.purple),
                            ),
                            Text(data.testText!)
                          ],
                        ),
                        leading: const Icon(Icons.developer_mode),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: "Delete",
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await RegexDao().delete(data.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Regex record deleted successfully")));
                                setState(() {});
                              },
                            ),
                            IconButton(
                              tooltip: "Copy Regex to clipboard",
                              onPressed: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: data.regex));
                              },
                              icon: const Icon(
                                Icons.copy,
                              ),
                            ),
                            IconButton(
                              tooltip: "Take Regex",
                              onPressed: () async {
                                Navigator.of(context).pop(data);
                              },
                              icon: const Icon(
                                Icons.play_arrow,
                              ),
                            ),
                            IconButton(
                              tooltip: "Take Regex and Test text",
                              onPressed: () async {
                                data.takeTestText = true;
                                Navigator.of(context).pop(data);
                              },
                              icon: const Icon(
                                Icons.fast_forward_outlined,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return const CircularProgressIndicator();
              },
            ),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
