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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your regex list"),
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
                  title: Text(data.name),
                  subtitle: Text(data.regex),
                  leading: const Icon(Icons.developer_mode),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
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
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: data.regex));
                          },
                          icon: const Icon(Icons.copy)),
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
}
