// lib/data/chatbot_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotAPI {
  // Android emulator -> PC localhost
  static const String baseUrl = "http://10.0.2.2:8001";

  static Future<Map<String, dynamic>> sendMessage(
    String message, {
    String? condition, // ✅ NEW optional param
  }) async {
    final Uri url = Uri.parse('$baseUrl/predict_intent');

    final Map<String, dynamic> body = {
      'message': message,
      if (condition != null) 'condition': condition, // ✅ include if present
    };

    try {
      final response = await http.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // Non-200 = server reachable but wrong path / error in backend
      return {
        'intent': 'error',
        'reply':
            "Sorry, I couldn’t connect to KuBot's NLP server. (Error ${response.statusCode})",
      };
    } catch (e) {
      // Network / DNS / server not running
      return {
        'intent': 'error',
        'reply':
            'Network error. Make sure the KuBot NLP server is running and your device is connected. ($e)',
      };
    }
  }
}
