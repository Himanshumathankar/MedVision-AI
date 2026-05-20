import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_container.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(predictionControllerProvider);
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Diagnostic Report'), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Patient Report', style: TextStyle(fontSize: 22, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  state.result == null ? 'Prediction: --' : 'Prediction: ${state.result!.label}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  state.result == null
                      ? 'Confidence: --'
                      : 'Confidence: ${(state.result!.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                if (state.reportUrl != null)
                  SelectableText(
                    state.reportUrl!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                const Spacer(),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: state.result == null
                          ? null
                          : () => ref.read(predictionControllerProvider.notifier).generateReport(),
                      icon: const Icon(Icons.download),
                      label: const Text('Download PDF'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: state.reportUrl == null
                          ? null
                          : () async {
                              final url = Uri.parse(state.reportUrl!);
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            },
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
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
