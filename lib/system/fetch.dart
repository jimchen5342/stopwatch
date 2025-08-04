// https://jimchen5342.github.io/database/stopwatch/stopwatch.json
import 'dart:convert';
import 'package:http/http.dart' as http;

String host = "https://jimchen5342.github.io/database/stopwatch/";

Future<List<dynamic>> fetch(String table) async {
  final response = await http.get(Uri.parse('${host + table}.json'));

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON.
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    // If the server did not return a 200 OK response, throw an exception.
    throw Exception('Failed to load album');
  }
}
