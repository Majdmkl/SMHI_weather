import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheStore {
  static const key = 'smhi_cache_v1';
  Future<void> saveMap(Map<String, dynamic> json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, jsonEncode(json));
  }
  Future<Map<String, dynamic>?> loadMap() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(key);
    return s == null ? null : (jsonDecode(s) as Map<String, dynamic>);
  }
}
