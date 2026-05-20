class UploadResponse {
  final String assetId;
  final String url;

  UploadResponse({required this.assetId, required this.url});

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      assetId: json['asset_id'] as String,
      url: json['url'] as String,
    );
  }
}

class PredictionResult {
  final String label;
  final double confidence;
  final double probability;
  final String riskLevel;
  final int processingTimeMs;
  final String? gradcamUrl;
  final List<double> shapValues;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.probability,
    required this.riskLevel,
    required this.processingTimeMs,
    required this.gradcamUrl,
    required this.shapValues,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      riskLevel: json['risk_level'] as String,
      processingTimeMs: (json['processing_time_ms'] as num).toInt(),
      gradcamUrl: json['gradcam_url'] as String?,
      shapValues: (json['shap_values'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class ReportResponse {
  final String reportUrl;

  ReportResponse({required this.reportUrl});

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(reportUrl: json['report_url'] as String);
  }
}

class HistoryItem {
  final String id;
  final DateTime createdAt;
  final String label;
  final double confidence;
  final String? imageUrl;

  HistoryItem({
    required this.id,
    required this.createdAt,
    required this.label,
    required this.confidence,
    required this.imageUrl,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }
}
