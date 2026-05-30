import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';
import '../../core/widgets/animated_gradient_background.dart';
import '../../core/widgets/glass_container.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('History'),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: GlassContainer(
            child: history.when(
              data: (items) => ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(color: Colors.white24),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(
                      item.label,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${(item.confidence * 100).toStringAsFixed(1)}% • ${item.createdAt.toLocal()}'
                          .split('.')
                          .first,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, _) => Center(
                child: Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
