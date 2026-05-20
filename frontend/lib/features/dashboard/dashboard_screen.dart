import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/animated_gradient_background.dart';
import '../../core/utils/responsive.dart';
import 'widgets/module_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final padding = EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24, vertical: 32);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: padding,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MedVision AI Dashboard', style: TextStyle(fontSize: 28, color: Colors.white)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/history'),
                        icon: const Icon(Icons.history, color: Colors.white70),
                      ),
                      IconButton(
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: isDesktop ? 2 : 1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: isDesktop ? 2.6 : 1.8,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ModuleCard(
                    title: 'Breast Cancer',
                    subtitle: 'Upload mammogram scans',
                    icon: Icons.favorite,
                    gradient: const [Color(0xFF2563EB), Color(0xFF7C3AED)],
                    onTap: () => context.go('/breast/upload'),
                  ),
                  ModuleCard(
                    title: 'Lung Cancer',
                    subtitle: 'Upload CT scans',
                    icon: Icons.air,
                    gradient: const [Color(0xFF0EA5E9), Color(0xFF22D3EE)],
                    onTap: () {},
                  ),
                  ModuleCard(
                    title: 'Brain Tumor',
                    subtitle: 'Upload MRI scans',
                    icon: Icons.psychology,
                    gradient: const [Color(0xFF4F46E5), Color(0xFF818CF8)],
                    onTap: () {},
                  ),
                  ModuleCard(
                    title: 'Skin Disease',
                    subtitle: 'Upload dermatology image',
                    icon: Icons.spa,
                    gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
