import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DB {
  Database? db;
  static final DB _instance = DB._internal();
  factory DB() {
    return _instance;
  }

  DB._internal();

  Future<Database> getDatabaseConnection() async {
    String? directory;

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir = await getApplicationSupportDirectory();
      directory = appDocumentsDir.path;
    }
    // final dbPath = await getDatabasesPath();
    final dbPath = await getDatabasesPath();
    db ??= await openDatabase(
      join(directory ?? dbPath, 'regex_craftsman4.db'),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE regex(id INTEGER PRIMARY KEY, name TXT NOT NULL UNIQUE, regex TEXT NOT NULL UNIQUE, test_text TEXT, insert_date_time TEXT)');
      },
      onUpgrade: (db, oldVersion, newVersion) => {if (newVersion >= 2) {}},
      version: 1,
    );
    return db!;
  }
}
