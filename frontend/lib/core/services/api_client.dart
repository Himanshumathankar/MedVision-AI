import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  String? token;

  void setToken(String? value) {
    token = value;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postJson(String path, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    request.headers.addAll(_headers(skipJson: true));
    final response = await request.send();
    final payload = await response.stream.bytesToString();
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  Map<String, String> _headers({bool skipJson = false}) {
    final headers = <String, String>{};
    if (!skipJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
