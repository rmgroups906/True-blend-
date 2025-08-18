import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Basic Authentication credentials
  static const String _username = 'admin';
  static const String _password = 'admin123';
  
  // Generate Basic Auth header
  static String get _basicAuthHeader {
    final credentials = base64Encode(utf8.encode('$_username:$_password'));
    return 'Basic $credentials';
  }

  static Future<Map<String, dynamic>> analyzeImage(String imagePath, String category) async {
    try {
    print('[ApiService] analyzeImage called with path: $imagePath and category: $category');

      // Emulator: localhost → 10.0.2.2 (for Android)
      final uri = Uri.parse('https://true-blend.in/api/java/analyze/image'); // Change to your IP for physical devices

      final request = http.MultipartRequest('POST', uri)
        ..fields['category'] = category
        ..headers['Authorization'] = _basicAuthHeader
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        print('[ApiService] API response: $decoded'); // <- Add this
        return decoded;
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('API error: $e');

      return {
        'safetyLevel': 3,
        'ingredients': [
          {
            'name': 'No Ingredients Detected',
            'safety': 'Unknown',
            'description': '',
          }
        ],
      };
    }
  }
}
