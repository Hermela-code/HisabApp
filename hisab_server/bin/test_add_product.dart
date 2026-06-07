import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Testing /add-product endpoint...');
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8080/add-product'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_id': 100,
        'branch_id': 8,
        'product_name': 'Test Product',
        'brand': 'Test Brand',
        'category': 'Mobile',
        'specification': '128GB',
        'selling_price': 200,
        'cost_price': 100,
        'total_stock': 10,
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
