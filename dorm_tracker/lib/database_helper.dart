import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dorm_tracker/models/dorm.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dorms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create dorms table
    await db.execute('''
      CREATE TABLE dorms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Create places table with a foreign key reference to dorms
    await db.execute('''
      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dorm_id INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (dorm_id) REFERENCES dorms (id) ON DELETE CASCADE
      )
    ''');
  }

  // Insert a dorm into the database
  Future<int> insertDorm(Dorm dorm) async {
    final db = await database;
    return await db.insert('dorms', {'name': dorm.name});
  }

  // Get all dorms from the database
  Future<List<Dorm>> fetchDorms() async {
    final db = await database;
    final dormsData = await db.query('dorms');

    List<Dorm> dorms = [];
    for (var dorm in dormsData) {
      List<String> places = await fetchPlaces(dorm['id'] as int);
      dorms.add(Dorm(id: dorm['id'] as int, name: dorm['name'] as String, places: places));
    }
    return dorms;
  }

  // Insert a place for a specific dorm
  Future<int> insertPlace(int dormId, String place) async {
    final db = await database;
    return await db.insert('places', {'dorm_id': dormId, 'name': place});
  }

  // Get places for a specific dorm
  Future<List<String>> fetchPlaces(int dormId) async {
    final db = await database;
    final placesData = await db.query('places', where: 'dorm_id = ?', whereArgs: [dormId]);

    return placesData.map((place) => place['name'] as String).toList();
  }

  // Update dorm name
  Future<int> updateDorm(Dorm dorm) async {
    final db = await database;
    return await db.update(
      'dorms',
      {'name': dorm.name},
      where: 'id = ?',
      whereArgs: [dorm.id],
    );
  }

  // Delete a place for a specific dorm
  Future<int> deletePlace(int dormId, String place) async {
    final db = await database;
    return await db.delete(
      'places',
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, place],
    );
  }

  // Update a place's name for a specific dorm
  Future<int> updatePlace(int dormId, String oldPlace, String newPlace) async {
    final db = await database;
    return await db.update(
      'places',
      {'name': newPlace},
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, oldPlace],
    );
  }

  // Delete a dorm and all associated places
  Future<int> deleteDorm(int dormId) async {
    final db = await database;
    // Delete places before deleting the dorm
    await db.delete('places', where: 'dorm_id = ?', whereArgs: [dormId]);
    return await db.delete('dorms', where: 'id = ?', whereArgs: [dormId]);
  }
}
