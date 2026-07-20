import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/library_entry.dart';

/// Local SQLite persistence for the user's rated/saved albums. This is the
/// only place the app writes data — everything else (Deezer catalog data)
/// is fetched fresh over the network and never stored server-side.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'soundscout.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE library_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            albumId INTEGER UNIQUE NOT NULL,
            title TEXT NOT NULL,
            artist TEXT NOT NULL,
            coverUrl TEXT NOT NULL,
            genre TEXT NOT NULL,
            rating INTEGER NOT NULL,
            review TEXT NOT NULL,
            dateAdded TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<LibraryEntry>> getAllEntries() async {
    final db = await _database;
    final rows = await db.query('library_entries', orderBy: 'dateAdded DESC');
    return rows.map((r) => LibraryEntry.fromMap(r)).toList();
  }

  Future<LibraryEntry?> getEntryByAlbumId(int albumId) async {
    final db = await _database;
    final rows = await db.query(
      'library_entries',
      where: 'albumId = ?',
      whereArgs: [albumId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LibraryEntry.fromMap(rows.first);
  }

  /// Inserts a new entry, or replaces the existing one for the same
  /// [LibraryEntry.albumId] (there's a UNIQUE constraint on albumId), so this
  /// single method covers both "save new rating" and "edit existing rating".
  Future<void> upsertEntry(LibraryEntry entry) async {
    final db = await _database;
    final map = entry.toMap()..remove('id');
    await db.insert(
      'library_entries',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntryByAlbumId(int albumId) async {
    final db = await _database;
    await db.delete('library_entries', where: 'albumId = ?', whereArgs: [albumId]);
  }
}
