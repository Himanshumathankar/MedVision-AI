import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
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
      headers: await _headersAsync(),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headersAsync(),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Uint8List bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    request.headers.addAll(await _headersAsync(skipJson: true));
    final response = await request.send();
    final payload = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = _readErrorDetail(payload);
      throw Exception('Request failed: ${response.statusCode} $detail');
    }
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = _readErrorDetail(response.body);
      throw Exception('Request failed: ${response.statusCode} $detail');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _readErrorDetail(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic> && json['detail'] != null) {
        return json['detail'].toString();
      }
      return body.isNotEmpty ? body : 'Unknown error';
    } catch (_) {
      return body.isNotEmpty ? body : 'Unknown error';
    }
  }

  Future<Map<String, String>> _headersAsync({bool skipJson = false}) async {
    final headers = <String, String>{};
    if (!skipJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firebaseToken = await user.getIdToken();
        if (firebaseToken != null) {
          headers['X-Firebase-Token'] = firebaseToken;
        }
      }
    } catch (_) {
      // Ignore token fetch failures; backend will handle auth errors.
    }
    return headers;
  }
}
