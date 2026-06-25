import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ThingsBoardClient {
  final String baseUrl;     
  final String accessToken; 
  const ThingsBoardClient({required this.baseUrl, required this.accessToken});

  Future<bool> postTelemetry(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/api/v1/$accessToken/telemetry');
    try {
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(payload))
          .timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false; 
    }
  }
}