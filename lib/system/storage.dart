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

  getString(String key) {
    var s = localStorage.getItem(key) ?? "[]";
    return s;
  }

  setString(String key, dynamic value) {
    localStorage.setItem(key, value);
  }

  getInt(String key, {int defaultVaule = 0}) {
    var s = localStorage.getItem(key) ?? "$defaultVaule";
    return int.parse(s);
  }

  setInt(String key, int value) {
    localStorage.setItem(key, value.toString());
  }

  List<dynamic> getJsonArray(String key) {
    var s = localStorage.getItem(key) ?? "[]";
    List<dynamic> dataList = jsonDecode(s);
    return dataList;
  }

  List<String> readStringArray(String key) {
    var s = localStorage.getItem(key) ?? "[]";
    List<String> dataList = jsonDecode(s);
    return dataList;
  }

  List<num> readNumberArray(String key) {
    var s = localStorage.getItem(key) ?? "[]";
    List<num> dataList = jsonDecode(s);
    return dataList;
  }

  void setJsonArray(String key, List<dynamic> array) {
    localStorage.setItem(key, jsonEncode(array));
  }

  void writeStringArray(String key, List<String> array) {
    localStorage.setItem(key, jsonEncode(array));
  }

  void writeNumberArray(String key, List<num> array) {
    localStorage.setItem(key, jsonEncode(array));
  }
}
