import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing /add-staff endpoint...');
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/add-staff'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'staff_id': 100,
        'branch_id': 8,
        'name': 'Test Staff',
        'role': 'Cashier',
        'phone': '12345678',
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
