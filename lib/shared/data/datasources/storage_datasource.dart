import 'package:shared_preferences/shared_preferences.dart';

// Abstract data source for storage operations
abstract class StorageDataSource {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> saveBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> saveInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> saveDouble(String key, double value);
  Future<double?> getDouble(String key);
  Future<void> saveStringList(String key, List<String> value);
  Future<List<String>?> getStringList(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<Set<String>> getKeys();
  Future<bool> containsKey(String key);
}

// Implementation using SharedPreferences

class StorageDataSourceImpl implements StorageDataSource {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> saveString(String key, String value) async {
    final preferences = await prefs;
    await preferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final preferences = await prefs;
    return preferences.getString(key);
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    final preferences = await prefs;
    await preferences.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    final preferences = await prefs;
    return preferences.getBool(key);
  }

  @override
  Future<void> saveInt(String key, int value) async {
    final preferences = await prefs;
    await preferences.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    final preferences = await prefs;
    return preferences.getInt(key);
  }

  @override
  Future<void> saveDouble(String key, double value) async {
    final preferences = await prefs;
    await preferences.setDouble(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    final preferences = await prefs;
    return preferences.getDouble(key);
  }

  @override
  Future<void> saveStringList(String key, List<String> value) async {
    final preferences = await prefs;
    await preferences.setStringList(key, value);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final preferences = await prefs;
    return preferences.getStringList(key);
  }

  @override
  Future<void> remove(String key) async {
    final preferences = await prefs;
    await preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    final preferences = await prefs;
    await preferences.clear();
  }

  @override
  Future<Set<String>> getKeys() async {
    final preferences = await prefs;
    return preferences.getKeys();
  }

  @override
  Future<bool> containsKey(String key) async {
    final preferences = await prefs;
    return preferences.containsKey(key);
  }
}
