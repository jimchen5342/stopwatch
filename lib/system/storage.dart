import 'dart:convert';
import 'package:localstorage/localstorage.dart';

class StorageManager {
  static final StorageManager _instance = StorageManager._internal();

  factory StorageManager() {
    return _instance;
  }

  StorageManager._internal();

  Future<void> initStorage() async {
    await initLocalStorage();
    // localStorage.clear();
  }

  clear() {
    localStorage.clear();
  }

  getItem(String key) {
    return localStorage.getItem(key);
  }

  setItem(String key, dynamic value) {
    localStorage.setItem(key, value);
  }

  Future<List<dynamic>> readJsonArray(String key) async {
    var s = localStorage.getItem(key) ?? "[]";
    List<dynamic> dataList = jsonDecode(s);
    return dataList;
  }

  Future<List<String>> readStringArray(String key) async {
    var s = localStorage.getItem(key) ?? "[]";
    List<String> dataList = jsonDecode(s);
    return dataList;
  }

  Future<List<num>> readNumberArray(String key) async {
    var s = localStorage.getItem(key) ?? "[]";
    List<num> dataList = jsonDecode(s);
    return dataList;
  }

  Future<void> writeJsonArray(String key, List<dynamic> array) async {
    localStorage.setItem(key, jsonEncode(array));
  }

  Future<void> writeStringArray(String key, List<String> array) async {
    localStorage.setItem(key, jsonEncode(array));
  }

  Future<void> writeNumberArray(String key, List<num> array) async {
    localStorage.setItem(key, jsonEncode(array));
  }
}
