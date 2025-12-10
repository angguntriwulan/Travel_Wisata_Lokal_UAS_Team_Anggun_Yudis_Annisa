import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wisata_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wisata_database.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wisata(
        id TEXT PRIMARY KEY,
        name TEXT,
        location TEXT,
        description TEXT,
        imageAsset TEXT,
        rating REAL,
        price TEXT,
        latitude REAL,
        longitude REAL,
        openTime TEXT,  -- Kolom baru
        closeTime TEXT,  -- Kolom baru
        category TEXT  -- Kolom baru
      )
    ''');
  }

  // 1. CREATE (Tambah Data)
  Future<int> insertWisata(Wisata wisata) async {
    Database db = await database;
    return await db.insert(
      'wisata',
      wisata.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. READ (Ambil Semua Data)
  Future<List<Wisata>> getWisataList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wisata');
    return List.generate(maps.length, (i) {
      return Wisata.fromMap(maps[i]);
    });
  }

  // 3. UPDATE (Ubah Data)
  Future<int> updateWisata(Wisata wisata) async {
    Database db = await database;
    return await db.update(
      'wisata',
      wisata.toMap(),
      where: 'id = ?',
      whereArgs: [wisata.id],
    );
  }

  // 4. DELETE (Hapus Data)
  Future<int> deleteWisata(String id) async {
    Database db = await database;
    return await db.delete('wisata', where: 'id = ?', whereArgs: [id]);
  }
}
