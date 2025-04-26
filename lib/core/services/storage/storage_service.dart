import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service for handling local storage operations
class StorageService {
  /// Shared preferences instance
  late SharedPreferences _prefs;
  
  /// SQLite database instance
  late Database _database;
  
  /// Whether the storage service is initialized
  bool _isInitialized = false;

  /// Initializes the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Initialize shared preferences
    _prefs = await SharedPreferences.getInstance();
    
    // Initialize SQLite database
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'chinese_odyssey.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
    
    _isInitialized = true;
  }

  /// Creates the database tables
  Future<void> _createDatabase(Database db, int version) async {
    // User table
    await db.execute('''
      CREATE TABLE User (
        userId TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        displayName TEXT,
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT,
        settings TEXT
      )
    ''');
    
    // HSK Level table
    await db.execute('''
      CREATE TABLE HskLevel (
        hskLevelId INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');
    
    // Grammar Point table
    await db.execute('''
      CREATE TABLE GrammarPoint (
        grammarPointId TEXT PRIMARY KEY,
        hskLevelId INTEGER NOT NULL,
        name TEXT NOT NULL,
        descriptionHtml TEXT,
        exampleSentenceChinese TEXT,
        exampleSentencePinyin TEXT,
        exampleSentenceTranslation TEXT,
        FOREIGN KEY (hskLevelId) REFERENCES HskLevel (hskLevelId)
      )
    ''');
    
    // Vocabulary table
    await db.execute('''
      CREATE TABLE Vocabulary (
        vocabularyId TEXT PRIMARY KEY,
        hskLevelId INTEGER NOT NULL,
        characters TEXT NOT NULL,
        pinyin TEXT NOT NULL,
        englishTranslation TEXT NOT NULL,
        partOfSpeech TEXT,
        audioPronunciationUrl TEXT,
        FOREIGN KEY (hskLevelId) REFERENCES HskLevel (hskLevelId)
      )
    ''');
    
    // Scenario table
    await db.execute('''
      CREATE TABLE Scenario (
        scenarioId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        isPredefined INTEGER NOT NULL,
        suggestedHskLevel INTEGER,
        createdByUserId TEXT,
        createdAt TEXT NOT NULL,
        lastUsedAt TEXT,
        syncStatus TEXT DEFAULT 'synced'
      )
    ''');
    
    // Conversation table
    await db.execute('''
      CREATE TABLE Conversation (
        conversationId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        scenarioId TEXT NOT NULL,
        scenarioName TEXT NOT NULL,
        hskLevelPlayed INTEGER NOT NULL,
        startedAt TEXT NOT NULL,
        endedAt TEXT,
        currentScore INTEGER NOT NULL,
        finalScore INTEGER,
        outcomeStatus TEXT NOT NULL,
        aiHiddenGoalDescription TEXT,
        savedInstanceDetails TEXT,
        syncStatus TEXT DEFAULT 'synced',
        FOREIGN KEY (scenarioId) REFERENCES Scenario (scenarioId)
      )
    ''');
    
    // Conversation Turn table
    await db.execute('''
      CREATE TABLE ConversationTurn (
        turnId TEXT PRIMARY KEY,
        conversationId TEXT NOT NULL,
        turnNumber INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        speaker TEXT NOT NULL,
        inputMode TEXT,
        userRawInput TEXT,
        userValidatedTranscript TEXT,
        aiResponseText TEXT,
        grammarPointsUsedCorrectlyIds TEXT,
        vocabularyUsedCorrectlyIds TEXT,
        identifiedErrors TEXT,
        scoreChange INTEGER,
        flaggedNewWordId TEXT,
        syncStatus TEXT DEFAULT 'synced',
        FOREIGN KEY (conversationId) REFERENCES Conversation (conversationId)
      )
    ''');
    
    // User Mastery Grammar table
    await db.execute('''
      CREATE TABLE UserMasteryGrammar (
        userId TEXT NOT NULL,
        grammarPointId TEXT NOT NULL,
        masteryScore REAL NOT NULL,
        correctStreak INTEGER NOT NULL,
        timesEncountered INTEGER NOT NULL,
        timesCorrect INTEGER NOT NULL,
        lastPracticedAt TEXT,
        lastUpdatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        PRIMARY KEY (userId, grammarPointId),
        FOREIGN KEY (grammarPointId) REFERENCES GrammarPoint (grammarPointId)
      )
    ''');
    
    // User Mastery Vocabulary table
    await db.execute('''
      CREATE TABLE UserMasteryVocabulary (
        userId TEXT NOT NULL,
        vocabularyId TEXT NOT NULL,
        masteryScore REAL NOT NULL,
        correctStreak INTEGER NOT NULL,
        timesEncountered INTEGER NOT NULL,
        timesCorrect INTEGER NOT NULL,
        lastPracticedAt TEXT,
        lastUpdatedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        PRIMARY KEY (userId, vocabularyId),
        FOREIGN KEY (vocabularyId) REFERENCES Vocabulary (vocabularyId)
      )
    ''');
    
    // User Saved Word table
    await db.execute('''
      CREATE TABLE UserSavedWord (
        savedWordId TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        conversationTurnId TEXT NOT NULL,
        wordCharacters TEXT NOT NULL,
        wordPinyin TEXT,
        contextualMeaning TEXT NOT NULL,
        exampleUsage TEXT NOT NULL,
        sourceHskLevel INTEGER,
        addedAt TEXT NOT NULL,
        syncStatus TEXT DEFAULT 'synced',
        FOREIGN KEY (conversationTurnId) REFERENCES ConversationTurn (turnId)
      )
    ''');
    
    // Sync Queue table for tracking changes that need to be synced
    await db.execute('''
      CREATE TABLE SyncQueue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityType TEXT NOT NULL,
        entityId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        retryCount INTEGER DEFAULT 0,
        lastRetryAt TEXT
      )
    ''');
  }

  /// Closes the database connection
  Future<void> close() async {
    if (_isInitialized) {
      await _database.close();
      _isInitialized = false;
    }
  }

  // Shared Preferences Methods

  /// Saves a string value to shared preferences
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Gets a string value from shared preferences
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Saves a boolean value to shared preferences
  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Gets a boolean value from shared preferences
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Saves an integer value to shared preferences
  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Gets an integer value from shared preferences
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Saves a JSON object to shared preferences
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }

  /// Gets a JSON object from shared preferences
  Map<String, dynamic>? getJson(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Removes a value from shared preferences
  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clears all values from shared preferences
  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Database Methods

  /// Inserts a record into the database
  Future<int> insert(String table, Map<String, dynamic> values) async {
    return await _database.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates a record in the database
  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    return await _database.update(
      table,
      values,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  /// Deletes a record from the database
  Future<int> delete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    return await _database.delete(
      table,
      where: whereClause,
      whereArgs: whereArgs,
    );
  }

  /// Executes a raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<dynamic> arguments,
  ) async {
    return await _database.rawQuery(sql, arguments);
  }

  /// Queries the database
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _database.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Executes a batch of operations
  Future<List<dynamic>> batch(Function(Batch batch) operations) async {
    final batch = _database.batch();
    operations(batch);
    return await batch.commit();
  }

  // File Storage Methods

  /// Saves a file to the app's documents directory
  Future<File> saveFile(String fileName, List<int> bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.writeAsBytes(bytes);
  }

  /// Reads a file from the app's documents directory
  Future<List<int>> readFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.readAsBytes();
  }

  /// Deletes a file from the app's documents directory
  Future<void> deleteFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Checks if a file exists in the app's documents directory
  Future<bool> fileExists(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    return await file.exists();
  }

  /// Lists all files in the app's documents directory
  Future<List<String>> listFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = await directory.list().toList();
    return files.map((file) => file.path.split('/').last).toList();
  }
}
