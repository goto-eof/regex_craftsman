import 'package:regex_craftsman/exception/dao_exception.dart';
import 'package:regex_craftsman/service/db_service.dart';
import 'package:regex_craftsman/model/regex.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RegexDao {
  final tableName = "regex";

  Future<int> insert(Regex regex) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();
      return await database.insert(
        tableName,
        regex.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<Regex?> getByName(final String regexName) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps = await database.query(
        tableName,
        orderBy: 'insert_date_time desc',
        where: 'name = ?',
        whereArgs: [regexName],
      );
      if (maps.isEmpty) {
        return null;
      }
      return Regex(
        name: maps[0]["name"],
        regex: maps[0]["regex"],
        testText: maps[0]["test_text"],
        insertDateTime: DateTime.parse(
          maps[0]["insert_date_time"],
        ),
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<int> count() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps =
          await database.rawQuery("select count(1) as num from regex");

      if (maps.isEmpty) {
        return 0;
      }
      return maps[0]["num"];
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<List<Regex>> list() async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      final List<Map<String, dynamic>> maps =
          await database.query(tableName, orderBy: 'insert_date_time desc');

      return List.generate(
        maps.length,
        (i) {
          return Regex(
            id: maps[i]["id"],
            name: maps[i]["name"],
            regex: maps[i]["regex"],
            testText: maps[i]["test_text"],
            insertDateTime: DateTime.parse(
              maps[i]["insert_date_time"],
            ),
          );
        },
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      DB db = DB();
      final database = await db.getDatabaseConnection();

      await database.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (err) {
      throw DaoException(cause: err.toString());
    }
  }

  void truncate() async {
    DB db = DB();
    final database = await db.getDatabaseConnection();
    await database.execute("delete from regex");
  }
}
