import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_datasource.dart';

// Concrete implementation of Storage Repository
class StorageRepositoryImpl implements StorageRepository {
  final StorageDataSource _dataSource;

  StorageRepositoryImpl(this._dataSource);

  @override
  Future<void> saveString(String key, String value) async {
    await _dataSource.saveString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return await _dataSource.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    await _dataSource.saveBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return await _dataSource.getBool(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    await _dataSource.saveInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return await _dataSource.getInt(key);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    await _dataSource.saveDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return await _dataSource.getDouble(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    await _dataSource.saveStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return await _dataSource.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    await _dataSource.remove(key);
  }

  @override
  Future<void> clear() async {
    await _dataSource.clear();
  }

  @override
  Future<Set<String>> getKeys() async {
    return await _dataSource.getKeys();
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _dataSource.containsKey(key);
  }
}
