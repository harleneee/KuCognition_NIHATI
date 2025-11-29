import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 👇 THIS is where the backend URL lives
  static const String apiUrl = "http://10.0.2.2:8000/predict";

  static Future<Map<String, dynamic>> predictNailDisease(File imageFile) async {
    var request = http.MultipartRequest("POST", Uri.parse(apiUrl));
    request.files.add(
      await http.MultipartFile.fromPath("file", imageFile.path),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to predict: ${response.statusCode}");
    }
  }
}
