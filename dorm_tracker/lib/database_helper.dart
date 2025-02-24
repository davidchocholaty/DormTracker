import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:dorm_tracker/models/dorm.dart';
import 'package:dorm_tracker/models/place.dart';

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
      place_id INTEGER NOT NULL, -- Foreign key referencing places
      name TEXT NOT NULL,
      count INTEGER DEFAULT 0,
      UNIQUE(place_id, name), -- Ensure unique items within the same place
      FOREIGN KEY (place_id) REFERENCES places (id) ON DELETE CASCADE
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
      List<Place> places = await fetchPlaces(dorm['id'] as int);
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

    // Check if the place already exists for the given dorm
    final existingPlace = await db.query(
      'places',
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, place],
    );

    // If place exists, throw an exception
    if (existingPlace.isNotEmpty) {
      throw Exception("Place with this name already exists.");
    }

    // If not exists, insert the place
    return await db.insert('places', {'dorm_id': dormId, 'name': place});
  }

  // Get places for a specific dorm
  Future<List<Place>> fetchPlaces(int dormId) async {
    final db = await instance.database;
    final placeMaps = await db.query(
      'places',
      where: 'dorm_id = ?',
      whereArgs: [dormId],
      orderBy: 'id ASC', // Maintain insertion order
    );

    // Convert the list of maps to a list of Place objects
    return placeMaps.map((placeMap) => Place.fromMap(placeMap)).toList();
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

    // Check if the old place exists for the given dorm
    final existingPlace = await db.query(
      'places',
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, oldPlace],
    );

    // If the old place doesn't exist, throw an exception
    if (existingPlace.isEmpty) {
      throw Exception("The place to update doesn't exist.");
    }

    // Check if the new place already exists for the given dorm
    final duplicatePlace = await db.query(
      'places',
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, newPlace],
    );

    // If new place already exists, throw an exception
    if (duplicatePlace.isNotEmpty) {
      throw Exception("Place with this new name already exists.");
    }

    // Proceed with the update if checks pass
    return await db.update(
      'places',
      {'name': newPlace},
      where: 'dorm_id = ? AND name = ?',
      whereArgs: [dormId, oldPlace],
    );
  }

  // Fetch items for a specific place
  Future<List<Map<String, dynamic>>> fetchItems(int placeId) async {
    final db = await instance.database;
    final result = await db.query(
      'items',
      where: 'place_id = ?',
      whereArgs: [placeId],
      orderBy: 'id ASC',
    );
    return result;
  }

  // Insert new item with default count of 0
  Future<void> insertItem(int placeId, String itemName, int count) async {
    final db = await instance.database;

    // Check if the item already exists in any place
    final existingItem = await db.query(
      'items',
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, itemName],
    );

    if (existingItem.isNotEmpty) {
      throw Exception("Item with this name already exists.");
    }

    // Insert the item if it's not a duplicate
    await db.insert(
      'items',
      {'place_id': placeId, 'name': itemName, 'count': count},
      conflictAlgorithm: ConflictAlgorithm.ignore, // Prevent crashing if unique constraint fails
    );
  }

  // Update item count
  Future<void> updateItemCount(int placeId, String itemName, int newCount) async {
    final db = await instance.database;
    await db.update(
      'items',
      {'count': newCount},
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, itemName],
    );
  }

  // Update item name in the database
  Future<void> updateItemName(int placeId, String oldItemName, String newItemName) async {
    final db = await instance.database;

    // Check if the item exists in the place (old name)
    final existingItem = await db.query(
      'items',
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, oldItemName],
    );

    if (existingItem.isEmpty) {
      throw Exception("The item to update doesn't exist.");
    }

    // Check if the new item name already exists in the same place
    final duplicateItem = await db.query(
      'items',
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, newItemName],
    );

    if (duplicateItem.isNotEmpty) {
      throw Exception("Item with this new name already exists.");
    }

    // Proceed with the update if checks pass
    await db.update(
      'items',
      {'name': newItemName},
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, oldItemName],
    );
  }

  // Delete an item
  Future<void> deleteItem(int placeId, String itemName) async {
    final db = await instance.database;
    await db.delete(
      'items',
      where: 'place_id = ? AND name = ?',
      whereArgs: [placeId, itemName],
    );
  }
}
