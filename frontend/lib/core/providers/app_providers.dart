import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prediction_models.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/medvision_api.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggle(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return 'http://localhost:8000';
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: ref.watch(apiBaseUrlProvider));
});

final medVisionApiProvider = Provider<MedVisionApi>((ref) {
  return MedVisionApi(ref.watch(apiClientProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  return AuthController(
    ref.watch(authServiceProvider),
    ref.watch(medVisionApiProvider),
    ref.watch(apiClientProvider),
  );
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  AuthController(this._auth, this._api, this._client) : super(AsyncValue.data(FirebaseAuth.instance.currentUser));

  final AuthService _auth;
  final MedVisionApi _api;
  final ApiClient _client;

  Future<void> signInEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithEmail(email, password);
      await _exchangeToken();
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signUpWithEmail(email, password);
      await _auth.sendEmailVerification();
      await _exchangeToken();
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordReset(email);
  }

  Future<void> signInGoogle() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithGoogle();
      await _exchangeToken();
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInApple() async {
    state = const AsyncValue.loading();
    try {
      final credential = await _auth.signInWithApple();
      await _exchangeToken();
      state = AsyncValue.data(credential.user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _client.setToken(null);
    state = const AsyncValue.data(null);
  }

  Future<void> _exchangeToken() async {
    final token = await _auth.idToken();
    if (token == null) return;
    final jwt = await _api.exchangeFirebaseToken(token);
    _client.setToken(jwt);
  }
}

class PredictionState {
  PredictionState({
    this.imageBytes,
    this.imageName,
    this.isUploading = false,
    this.isPredicting = false,
    this.error,
    this.upload,
    this.result,
    this.reportUrl,
  });

  final Uint8List? imageBytes;
  final String? imageName;
  final bool isUploading;
  final bool isPredicting;
  final String? error;
  final UploadResponse? upload;
  final PredictionResult? result;
  final String? reportUrl;

  PredictionState copyWith({
    Uint8List? imageBytes,
    String? imageName,
    bool? isUploading,
    bool? isPredicting,
    String? error,
    UploadResponse? upload,
    PredictionResult? result,
    String? reportUrl,
  }) {
    return PredictionState(
      imageBytes: imageBytes ?? this.imageBytes,
      imageName: imageName ?? this.imageName,
      isUploading: isUploading ?? this.isUploading,
      isPredicting: isPredicting ?? this.isPredicting,
      error: error,
      upload: upload ?? this.upload,
      result: result ?? this.result,
      reportUrl: reportUrl ?? this.reportUrl,
    );
  }
}

final predictionControllerProvider = StateNotifierProvider<PredictionController, PredictionState>((ref) {
  return PredictionController(ref.watch(medVisionApiProvider));
});

class PredictionController extends StateNotifier<PredictionState> {
  PredictionController(this._api) : super(PredictionState());

  final MedVisionApi _api;

  void setImage(Uint8List bytes, String name) {
    state = state.copyWith(imageBytes: bytes, imageName: name, error: null);
  }

  Future<void> uploadAndPredict() async {
    if (state.imageBytes == null || state.imageName == null) {
      state = state.copyWith(error: 'Select an image first.');
      return;
    }
    try {
      state = state.copyWith(isUploading: true, error: null);
      final upload = await _api.uploadImage(state.imageBytes!, state.imageName!);
      state = state.copyWith(isUploading: false, isPredicting: true, upload: upload);
      final result = await _api.predictBreastCancer(upload.url);
      state = state.copyWith(isPredicting: false, result: result);
    } catch (e) {
      state = state.copyWith(isUploading: false, isPredicting: false, error: e.toString());
    }
  }

  Future<void> generateReport() async {
    final result = state.result;
    if (result == null) return;
    final payload = {
      'prediction': {
        'label': result.label,
        'confidence': result.confidence,
        'probability': result.probability,
        'risk_level': result.riskLevel,
        'processing_time_ms': result.processingTimeMs,
        'gradcam_url': result.gradcamUrl,
        'shap_values': result.shapValues,
      },
      'patient_name': 'MedVision User',
      'patient_id': 'MV-001',
    };
    final report = await _api.generateReport(payload);
    state = state.copyWith(reportUrl: report.reportUrl);
  }
}

final historyProvider = FutureProvider<List<HistoryItem>>((ref) async {
  return ref.watch(medVisionApiProvider).getHistory();
});
