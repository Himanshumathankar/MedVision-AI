import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_container.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(predictionControllerProvider);
    final result = state.result;
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Results'),
          backgroundColor: Colors.transparent,
          actions: [
            TextButton(onPressed: () => context.go('/breast/report'), child: const Text('Report')),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result == null ? 'No prediction yet' : 'Prediction: ${result.label}',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  result == null ? 'Confidence: --' : 'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black26,
                          child: state.upload?.url != null
                              ? Image.network(state.upload!.url, fit: BoxFit.cover)
                              : const Center(child: Text('Original Image', style: TextStyle(color: Colors.white70))),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          color: Colors.black26,
                          child: result?.gradcamUrl != null
                              ? Image.network(result!.gradcamUrl!, fit: BoxFit.cover)
                              : const Center(child: Text('Grad-CAM Overlay', style: TextStyle(color: Colors.white70))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      Expanded(
                        child: _RiskMeter(probability: result?.probability ?? 0),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ConfidenceChart(value: result?.confidence ?? 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go('/breast/explain'),
                      child: const Text('Explainability'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Back to Dashboard'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiskMeter extends StatelessWidget {
  const _RiskMeter({required this.probability});

  final double probability;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: probability),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, _) {
        return CustomPaint(
          painter: _RiskMeterPainter(value),
          child: Center(
            child: Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }
}

class _RiskMeterPainter extends CustomPainter {
  _RiskMeterPainter(this.probability);

  final double probability;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    final basePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, basePaint);

    final riskPaint = Paint()
      ..color = probability > 0.7 ? Colors.redAccent : probability > 0.4 ? Colors.orangeAccent : Colors.greenAccent
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * probability,
      false,
      riskPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ConfidenceChart extends StatelessWidget {
  const _ConfidenceChart({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      builder: (context, animValue, _) {
        return CustomPaint(
          painter: _ConfidencePainter(animValue),
          child: const Center(
            child: Text('Confidence Trend', style: TextStyle(color: Colors.white70)),
          ),
        );
      },
    );
  }
}

class _ConfidencePainter extends CustomPainter {
  _ConfidencePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * (1 - value));
    path.lineTo(size.width * 0.4, size.height * (1 - value * 0.8));
    path.lineTo(size.width * 0.7, size.height * (1 - value * 0.9));
    path.lineTo(size.width, size.height * (1 - value));
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
