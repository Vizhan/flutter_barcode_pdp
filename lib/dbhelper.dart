import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'barcode.dart';

class DbHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "barcode,db");

    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Barcode(id INTEGER PRIMARY KEY, barcodeSequence TEXT)');
  }

  Future<List<String>> getBarCodes() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Barcode');
    List<String> barCodes = new List();
    for (int i = 0; i < list.length; i++) {
      barCodes.add(list[i]["barcodeSequence"]);
    }

    return barCodes;
  }

  void saveBarCode(BarCode barcode) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn
          .rawInsert('INSERT INTO Barcode(barcodeSequence) VALUES("${barcode
          .barcodeSequence}")');
    });
  }

  void nukeDatabase() async {
    await _db.execute('DELETE FROM Barcode');
  }

  Future closeDb() async => _db.close();
}
