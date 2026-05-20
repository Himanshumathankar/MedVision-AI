import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/animated_gradient_background.dart';
import '../../core/widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardItem> _items = const [
    _OnboardItem(
      title: 'AI Diagnostics',
      subtitle: 'Upload medical scans and receive instant clinical insights.',
      icon: Icons.auto_graph,
    ),
    _OnboardItem(
      title: 'Explainability',
      subtitle: 'Grad-CAM and SHAP visualizations reveal model reasoning.',
      icon: Icons.visibility,
    ),
    _OnboardItem(
      title: 'Multi-Disease Platform',
      subtitle: 'Modular system ready for lung, brain, skin, and eye care.',
      icon: Icons.hub,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Center(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, color: Colors.white, size: 64),
                            const SizedBox(height: 16),
                            Text(item.title, style: const TextStyle(fontSize: 28, color: Colors.white)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 280,
                              child: Text(item.subtitle, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _items.length,
                        (i) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: _index == i ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _index == i ? Colors.white : Colors.white30,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Get Started', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _OnboardItem({required this.title, required this.subtitle, required this.icon});
}
