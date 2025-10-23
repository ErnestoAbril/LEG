import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryRepository {
  static const String _keyCustomCats = 'custom_categories';
  static const String _keyLanguage = 'user_language';

  static Future<List<String>> getCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_keyCustomCats);
    if (s == null) return [];
    try {
      final List<dynamic> data = jsonDecode(s);
      return data.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setCustomCategories(List<String> cats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomCats, jsonEncode(cats));
  }

  static Future<void> addCategory(String cat) async {
    final list = await getCustomCategories();
    if (!list.contains(cat)) {
      list.add(cat);
      await setCustomCategories(list);
    }
  }

  static Future<void> removeCategory(String cat) async {
    final list = await getCustomCategories();
    list.removeWhere((c) => c == cat);
    await setCustomCategories(list);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguage);
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }
}
