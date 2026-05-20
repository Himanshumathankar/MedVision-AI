import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_container.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final List<String> _steps = const [
    'Analyzing tissues...',
    'Detecting abnormalities...',
    'Generating explainability heatmap...',
    'Preparing diagnostic report...',
  ];
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  Future<void> _tick() async {
    for (var i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _index = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(predictionControllerProvider, (previous, next) {
      if (next.result != null && mounted) {
        context.go('/breast/results');
      }
    });
    final state = ref.watch(predictionControllerProvider);
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: GlassContainer(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(_steps[_index], style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(
                    state.isUploading || state.isPredicting ? 'Processing...' : 'Waiting for analysis',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(state.error!, style: const TextStyle(color: Colors.redAccent)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
