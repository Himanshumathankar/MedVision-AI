import 'dart:typed_data';
import '../models/prediction_models.dart';
import 'api_client.dart';

class MedVisionApi {
  MedVisionApi(this._client);

  final ApiClient _client;

  Future<UploadResponse> uploadImage(Uint8List bytes, String filename) async {
    final json = await _client.postMultipart('/upload/image', bytes: bytes, filename: filename);
    return UploadResponse.fromJson(json);
  }

  Future<PredictionResult> predictBreastCancer(String imageUrl) async {
    final json = await _client.postJson('/predict/breast-cancer', {'image_url': imageUrl});
    return PredictionResult.fromJson(json);
  }

  Future<ReportResponse> generateReport(Map<String, dynamic> payload) async {
    final json = await _client.postJson('/report/generate', payload);
    return ReportResponse.fromJson(json);
  }

  Future<List<HistoryItem>> getHistory() async {
    final json = await _client.get('/history/');
    final items = json['items'] as List<dynamic>? ?? [];
    return items.map((e) => HistoryItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> exchangeFirebaseToken(String firebaseToken) async {
    final json = await _client.postJson('/auth/exchange', {'firebase_token': firebaseToken});
    return json['access_token'] as String;
  }
}
