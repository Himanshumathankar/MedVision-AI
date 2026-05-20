import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/animated_gradient_background.dart';
import '../../core/widgets/glass_container.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Dr. Ava Carter', style: TextStyle(color: Colors.white)),
                  subtitle: Text('ava@medvision.ai', style: TextStyle(color: Colors.white70)),
                ),
                const Divider(color: Colors.white24),
                SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
                  value: isDark,
                  onChanged: (value) => ref.read(themeModeProvider.notifier).toggle(value),
                ),
                ListTile(
                  title: const Text('Language', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('English', style: TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: () {},
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
