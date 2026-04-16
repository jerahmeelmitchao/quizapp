import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/quiz.dart';

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000';
  static const String baseUrl = 'http://192.168.1.9:8000';

  static Future<Quiz> generateQuiz(File file) async {
    final uri = Uri.parse('$baseUrl/api/generate-quiz');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("SUCCESS: $data");
      return Quiz.fromJson(data);
    } else {
      print("ERROR ${response.statusCode}: ${response.body}");
      throw Exception('Failed to generate quiz: ${response.body}');
    }
  }
  
}
