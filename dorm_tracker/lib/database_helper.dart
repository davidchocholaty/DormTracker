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
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Create places table with a foreign key reference to dorms
    await db.execute('''
      CREATE TABLE places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dorm_id INTEGER,
        name TEXT NOT NULL,
        FOREIGN KEY (dorm_id) REFERENCES dorms (id) ON DELETE CASCADE,
        UNIQUE(dorm_id, name)  -- Ensures unique place names per dorm, but same names can exist in different dorms
      )
    ''');

    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        placeName TEXT NOT NULL,
        name TEXT NOT NULL,
        count INTEGER DEFAULT 0,
        UNIQUE(placeName, name) -- Allow duplicates across places but not within the same place
      )
    ''');
  }

  // Insert a dorm into the database, ensuring the dorm name is unique
  Future<int> insertDorm(Dorm dorm) async {
    final db = await database;

    // Check if a dorm with the same name already exists
    final existingDorm = await db.query(
      'dorms',
      where: 'name = ?',
      whereArgs: [dorm.name],
    );

    // If a dorm with the same name already exists, throw an exception
    if (existingDorm.isNotEmpty) {
      throw Exception("A dorm with this name already exists.");
    }

    // If no duplicate is found, insert the new dorm
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

  // Update dorm name, ensuring the new name is unique
  Future<int> updateDorm(Dorm dorm) async {
    final db = await database;

    // Check if a dorm with the same name already exists (excluding the dorm being updated)
    final existingDorm = await db.query(
      'dorms',
      where: 'name = ? AND id != ?',
      whereArgs: [dorm.name, dorm.id], // Check for other dorms with the same name
    );

    // If a dorm with the same name already exists, throw an exception
    if (existingDorm.isNotEmpty) {
      throw Exception("A dorm with this name already exists.");
    }

    // If no duplicate is found, update the dorm name
    return await db.update(
      'dorms',
      {'name': dorm.name},
      where: 'id = ?',
      whereArgs: [dorm.id],
    );
  }

  // Delete a dorm and all associated places
  Future<int> deleteDorm(int dormId) async {
    final db = await database;
    // Delete places before deleting the dorm
    await db.delete('places', where: 'dorm_id = ?', whereArgs: [dormId]);
    return await db.delete('dorms', where: 'id = ?', whereArgs: [dormId]);
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

  // Fetch items for a specific place
  Future<List<Map<String, dynamic>>> fetchItems(String placeName) async {
    final db = await instance.database;
    final result = await db.query(
      'items',
      where: 'placeName = ?',
      whereArgs: [placeName],
    );
    return result;
  }

  // Insert new item with default count of 0
  Future<void> insertItem(String placeName, String itemName, int count) async {
    final db = await instance.database;

    // Check if the item already exists in any place
    final existingItem = await db.query(
      'items',
      where: 'placeName = ? AND name = ?',
      whereArgs: [placeName, itemName],
    );


    if (existingItem.isNotEmpty) {
      throw Exception("Item with this name already exists.");
    }

    // Insert the item if it's not a duplicate
    await db.insert(
      'items',
      {'placeName': placeName, 'name': itemName, 'count': count},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Prevent crashing if unique constraint fails
    );
  }

  // Update item count
  Future<void> updateItemCount(String placeName, String itemName, int newCount) async {
    final db = await instance.database;
    await db.update(
      'items',
      {'count': newCount},
      where: 'placeName = ? AND name = ?',
      whereArgs: [placeName, itemName],
    );
  }

  // Delete an item
  Future<void> deleteItem(String placeName, String itemName) async {
    final db = await instance.database;
    await db.delete(
      'items',
      where: 'placeName = ? AND name = ?',
      whereArgs: [placeName, itemName],
    );
  }
}
