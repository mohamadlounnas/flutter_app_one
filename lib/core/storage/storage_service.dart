import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

/// Local storage service using SharedPreferences
class StorageService {
  SharedPreferences? _prefs;

  /// Initialize the storage service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure prefs is initialized
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _preferences.setString(AppConstants.tokenKey, token);
  }

  /// Get authentication token
  String? getToken() {
    return _preferences.getString(AppConstants.tokenKey);
  }

  /// Remove authentication token
  Future<void> removeToken() async {
    await _preferences.remove(AppConstants.tokenKey);
  }

  /// Save user data as JSON
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _preferences.setString(AppConstants.userKey, jsonEncode(userData));
  }

  /// Get user data as Map
  Map<String, dynamic>? getUser() {
    final userJson = _preferences.getString(AppConstants.userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// Remove user data
  Future<void> removeUser() async {
    await _preferences.remove(AppConstants.userKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _preferences.clear();
  }

  /// Save a string value
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  /// Get a string value
  String? getString(String key) {
    return _preferences.getString(key);
  }

  /// Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  /// Get a boolean value
  bool? getBool(String key) {
    return _preferences.getBool(key);
  }

  /// Save an integer value
  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  /// Get an integer value
  int? getInt(String key) {
    return _preferences.getInt(key);
  }

  /// Remove a specific key
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }
}
