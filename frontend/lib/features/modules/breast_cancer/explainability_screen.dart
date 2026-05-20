import 'package:flutter/material.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_container.dart';

class ExplainabilityScreen extends StatefulWidget {
  const ExplainabilityScreen({super.key});

  @override
  State<ExplainabilityScreen> createState() => _ExplainabilityScreenState();
}

class _ExplainabilityScreenState extends State<ExplainabilityScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Explainability'), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: [_tab == 0, _tab == 1, _tab == 2],
                  onPressed: (index) => setState(() => _tab = index),
                  children: const [
                    Padding(padding: EdgeInsets.all(12), child: Text('Original')),
                    Padding(padding: EdgeInsets.all(12), child: Text('Heatmap')),
                    Padding(padding: EdgeInsets.all(12), child: Text('Overlay')),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: Text(
                        _tab == 0 ? 'Original Image' : _tab == 1 ? 'Heatmap' : 'Overlay',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
