import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/manga_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manga_journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE manga_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        volume TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT NOT NULL,
        scannedText TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // --- CRUD ---

  Future<int> insertEntry(MangaEntry entry) async {
    final db = await database;
    return await db.insert(
      'manga_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MangaEntry>> getAllEntries() async {
    final db = await database;
    final maps = await db.query(
      'manga_entries',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MangaEntry.fromMap(map)).toList();
  }

  Future<List<MangaEntry>> getEntriesByStatus(String status) async {
    final db = await database;
    final maps = await db.query(
      'manga_entries',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => MangaEntry.fromMap(map)).toList();
  }

  Future<int> updateEntry(MangaEntry entry) async {
    final db = await database;
    return await db.update(
      'manga_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      'manga_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getStatusCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM manga_entries
      GROUP BY status
    ''');

    final counts = <String, int>{
      'Reading': 0,
      'Completed': 0,
      'Wishlist': 0,
    };

    for (final row in result) {
      counts[row['status'] as String] = row['count'] as int;
    }

    return counts;
  }
}
