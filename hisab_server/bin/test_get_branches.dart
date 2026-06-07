import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing GET /branches...');
  try {
    final response = await http.get(Uri.parse('http://localhost:8080/branches'));
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
