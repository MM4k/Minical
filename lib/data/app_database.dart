import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens (and caches) the single SQLite database used by the app.
///
/// On desktop (Windows/Linux/macOS) it uses the FFI factory; on Android/iOS it
/// uses the default sqflite factory.
class AppDatabase {
  AppDatabase._();

  static Database? _db;

  static Future<Database> instance() async {
    final existing = _db;
    if (existing != null) return existing;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      databaseFactory = databaseFactorySqflitePlugin;
    }

    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, 'minical.db');

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _onCreate,
      ),
    );
    _db = db;
    return db;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category_id INTEGER,
        start INTEGER NOT NULL,
        duration_minutes INTEGER NOT NULL,
        recurrence TEXT NOT NULL,
        recurrence_until INTEGER,
        notify_minutes_before INTEGER,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
      )
    ''');

    // Seed a couple of starter categories (the user can rename or delete them).
    await db.insert('categories', {'name': 'Personal', 'color': 0xFF16A34A});
    await db.insert('categories', {'name': 'Work', 'color': 0xFF2563EB});
  }
}
