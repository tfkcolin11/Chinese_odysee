import 'package:chinese_odysee/core/services/api/api_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';
import 'package:sqflite/sqflite.dart';

/// Base repository class for handling data operations
abstract class BaseRepository<T> {
  /// API service for remote operations
  final ApiService apiService;

  /// Storage service for local operations
  final StorageService storageService;

  /// Table name in the local database
  final String tableName;

  /// Whether the repository is in offline mode
  bool _offlineMode = false;

  /// Creates a new [BaseRepository] instance
  BaseRepository({
    required this.apiService,
    required this.storageService,
    required this.tableName,
  });

  /// Sets the offline mode
  void setOfflineMode(bool value) {
    _offlineMode = value;
  }

  /// Gets the offline mode
  bool get isOfflineMode => _offlineMode;

  /// Converts a model to a map
  Map<String, dynamic> toMap(T model);

  /// Creates a model from a map
  T fromMap(Map<String, dynamic> map);

  /// Gets the ID field name
  String get idField;

  /// Gets the ID value from a model
  String getIdValue(T model);

  /// Gets all items
  Future<List<T>> getAll() async {
    try {
      if (_offlineMode) {
        return await _getAllLocal();
      } else {
        try {
          final items = await _getAllRemote();
          await _saveAllLocal(items);
          return items;
        } catch (e) {
          // If remote fetch fails, fall back to local data
          return await _getAllLocal();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Gets an item by ID
  Future<T?> getById(String id) async {
    try {
      if (_offlineMode) {
        return await _getByIdLocal(id);
      } else {
        try {
          final item = await _getByIdRemote(id);
          if (item != null) {
            await _saveLocal(item);
          }
          return item;
        } catch (e) {
          // If remote fetch fails, fall back to local data
          return await _getByIdLocal(id);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new item
  Future<T> create(T item) async {
    try {
      if (_offlineMode) {
        await _saveLocal(item, syncStatus: 'pending_create');
        return item;
      } else {
        try {
          final createdItem = await _createRemote(item);
          await _saveLocal(createdItem);
          return createdItem;
        } catch (e) {
          // If remote creation fails, save locally with pending status
          await _saveLocal(item, syncStatus: 'pending_create');
          return item;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an item
  Future<T> update(T item) async {
    try {
      if (_offlineMode) {
        await _saveLocal(item, syncStatus: 'pending_update');
        return item;
      } else {
        try {
          final updatedItem = await _updateRemote(item);
          await _saveLocal(updatedItem);
          return updatedItem;
        } catch (e) {
          // If remote update fails, save locally with pending status
          await _saveLocal(item, syncStatus: 'pending_update');
          return item;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes an item
  Future<bool> delete(String id) async {
    try {
      if (_offlineMode) {
        await _markForDeletion(id);
        return true;
      } else {
        try {
          final success = await _deleteRemote(id);
          if (success) {
            await _deleteLocal(id);
          }
          return success;
        } catch (e) {
          // If remote deletion fails, mark for deletion locally
          await _markForDeletion(id);
          return true;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Synchronizes pending changes with the remote server
  Future<void> syncPendingChanges() async {
    if (_offlineMode) return;

    try {
      // Get items marked for creation
      final pendingCreates = await storageService.query(
        tableName,
        where: 'syncStatus = ?',
        whereArgs: ['pending_create'],
      );

      // Get items marked for update
      final pendingUpdates = await storageService.query(
        tableName,
        where: 'syncStatus = ?',
        whereArgs: ['pending_update'],
      );

      // Get items marked for deletion
      final pendingDeletes = await storageService.query(
        tableName,
        where: 'syncStatus = ?',
        whereArgs: ['pending_delete'],
      );

      // Process pending creations
      for (final item in pendingCreates) {
        try {
          final model = fromMap(item);
          final createdItem = await _createRemote(model);
          await _saveLocal(createdItem);
        } catch (e) {
          // Keep the pending status if sync fails
          continue;
        }
      }

      // Process pending updates
      for (final item in pendingUpdates) {
        try {
          final model = fromMap(item);
          final updatedItem = await _updateRemote(model);
          await _saveLocal(updatedItem);
        } catch (e) {
          // Keep the pending status if sync fails
          continue;
        }
      }

      // Process pending deletions
      for (final item in pendingDeletes) {
        try {
          final id = item[idField] as String;
          final success = await _deleteRemote(id);
          if (success) {
            await _deleteLocal(id);
          }
        } catch (e) {
          // Keep the pending status if sync fails
          continue;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Local storage operations

  /// Gets all items from local storage
  Future<List<T>> _getAllLocal() async {
    try {
      final maps = await storageService.query(
        tableName,
        where: 'syncStatus != ?',
        whereArgs: ['pending_delete'],
      );
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Gets an item by ID from local storage
  Future<T?> _getByIdLocal(String id) async {
    try {
      final maps = await storageService.query(
        tableName,
        where: '$idField = ? AND syncStatus != ?',
        whereArgs: [id, 'pending_delete'],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  /// Saves an item to local storage
  /// This is protected (accessible to subclasses)
  Future<void> saveLocal(T item, {String syncStatus = 'synced'}) async {
    try {
      final map = toMap(item);
      map['syncStatus'] = syncStatus;

      await storageService.insert(tableName, map);
    } catch (e) {
      rethrow;
    }
  }

  // Private alias for internal use
  Future<void> _saveLocal(T item, {String syncStatus = 'synced'}) async {
    return saveLocal(item, syncStatus: syncStatus);
  }

  /// Saves multiple items to local storage
  /// This is protected (accessible to subclasses)
  Future<void> saveAllLocal(List<T> items) async {
    try {
      batch(batch) {
        for (final item in items) {
          final map = toMap(item);
          map['syncStatus'] = 'synced';
          batch.insert(
            tableName,
            map,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      await storageService.batch(batch);
    } catch (e) {
      rethrow;
    }
  }

  // Private alias for internal use
  Future<void> _saveAllLocal(List<T> items) async {
    return saveAllLocal(items);
  }

  /// Deletes an item from local storage
  Future<void> _deleteLocal(String id) async {
    try {
      await storageService.delete(
        tableName,
        '$idField = ?',
        [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Marks an item for deletion in local storage
  Future<void> _markForDeletion(String id) async {
    try {
      await storageService.update(
        tableName,
        {'syncStatus': 'pending_delete'},
        '$idField = ?',
        [id],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Remote API operations

  /// Gets all items from the remote API
  Future<List<T>> _getAllRemote();

  /// Gets an item by ID from the remote API
  Future<T?> _getByIdRemote(String id);

  /// Creates an item in the remote API
  Future<T> _createRemote(T item);

  /// Updates an item in the remote API
  Future<T> _updateRemote(T item);

  /// Deletes an item from the remote API
  Future<bool> _deleteRemote(String id);
}
