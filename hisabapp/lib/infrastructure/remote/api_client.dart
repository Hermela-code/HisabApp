import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({this.baseUrl = 'http://127.0.0.1:8080', http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await _client.post(Uri.parse('$baseUrl$path'), body: jsonEncode(body), headers: {'content-type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('API error ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await _client.get(Uri.parse('$baseUrl$path'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('API error ${res.statusCode}: ${res.body}');
  }
}
