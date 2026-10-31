import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';

class DatabaseHelper {
  static const String _databaseName = 'contacts_manager.db';
  static const int _databaseVersion = 1;

  // Table & Columns
  static const String tableContacts = 'contacts';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnPhone = 'phone';
  static const String columnEmail = 'email';
  static const String columnAddress = 'address';
  static const String columnIsFavorite = 'is_favorite';

  // Singleton instance
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;
  bool _useFallback = false;
  final List<Contact> _fallbackContacts = [];
  int _fallbackNextId = 1;

  Future<Database?> get database async {
    if (_useFallback) return null;
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint('SQLite init failed ($e). Using in-memory database fallback.');
      _useFallback = true;
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      path = _databaseName;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _databaseName);
    }

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableContacts (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnPhone TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnAddress TEXT NOT NULL,
        $columnIsFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Insert a new contact into database. Returns generated ID.
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    if (db != null) {
      return await db.insert(
        tableContacts,
        contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final newId = _fallbackNextId++;
    final created = contact.copyWith(id: newId);
    _fallbackContacts.add(created);
    return newId;
  }

  /// Retrieve all contacts sorted alphabetically by name.
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        tableContacts,
        orderBy: '$columnName COLLATE NOCASE ASC',
      );
      return maps.map((map) => Contact.fromMap(map)).toList();
    }

    final list = List<Contact>.from(_fallbackContacts);
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Retrieve only favorite contacts.
  Future<List<Contact>> getFavoriteContacts() async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        tableContacts,
        where: '$columnIsFavorite = ?',
        whereArgs: [1],
        orderBy: '$columnName COLLATE NOCASE ASC',
      );
      return maps.map((map) => Contact.fromMap(map)).toList();
    }

    final list = _fallbackContacts.where((c) => c.isFavorite).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  /// Search contacts by name (case-insensitive substring match).
  Future<List<Contact>> searchContacts(String query, {bool favoritesOnly = false}) async {
    final trimmed = query.trim().toLowerCase();
    final db = await database;

    if (db != null) {
      if (favoritesOnly) {
        final List<Map<String, dynamic>> maps = await db.query(
          tableContacts,
          where: '$columnName LIKE ? AND $columnIsFavorite = ?',
          whereArgs: ['%$trimmed%', 1],
          orderBy: '$columnName COLLATE NOCASE ASC',
        );
        return maps.map((map) => Contact.fromMap(map)).toList();
      } else {
        final List<Map<String, dynamic>> maps = await db.query(
          tableContacts,
          where: '$columnName LIKE ?',
          whereArgs: ['%$trimmed%'],
          orderBy: '$columnName COLLATE NOCASE ASC',
        );
        return maps.map((map) => Contact.fromMap(map)).toList();
      }
    }

    final filtered = _fallbackContacts.where((c) {
      final matchesName = c.name.toLowerCase().contains(trimmed);
      if (favoritesOnly) {
        return matchesName && c.isFavorite;
      }
      return matchesName;
    }).toList();

    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  /// Fetch a single contact by its ID.
  Future<Contact?> getContactById(int id) async {
    final db = await database;
    if (db != null) {
      final List<Map<String, dynamic>> maps = await db.query(
        tableContacts,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Contact.fromMap(maps.first);
      }
      return null;
    }

    try {
      return _fallbackContacts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update an existing contact.
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    if (db != null) {
      return await db.update(
        tableContacts,
        contact.toMap(),
        where: '$columnId = ?',
        whereArgs: [contact.id],
      );
    }

    final index = _fallbackContacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _fallbackContacts[index] = contact;
      return 1;
    }
    return 0;
  }

  /// Delete a contact by ID.
  Future<int> deleteContact(int id) async {
    final db = await database;
    if (db != null) {
      return await db.delete(
        tableContacts,
        where: '$columnId = ?',
        whereArgs: [id],
      );
    }

    final countBefore = _fallbackContacts.length;
    _fallbackContacts.removeWhere((c) => c.id == id);
    return countBefore - _fallbackContacts.length;
  }

  /// Toggle favorite status of a contact.
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    if (db != null) {
      return await db.update(
        tableContacts,
        {columnIsFavorite: isFavorite ? 1 : 0},
        where: '$columnId = ?',
        whereArgs: [id],
      );
    }

    final index = _fallbackContacts.indexWhere((c) => c.id == id);
    if (index != -1) {
      _fallbackContacts[index] = _fallbackContacts[index].copyWith(isFavorite: isFavorite);
      return 1;
    }
    return 0;
  }

  /// Close database connection.
  Future<void> close() async {
    final db = await database;
    if (db != null) {
      await db.close();
    }
  }
}
