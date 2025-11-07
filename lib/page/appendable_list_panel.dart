import 'package:flutter/material.dart';
import 'package:nuitri_pilot_frontend/core/di.dart';
import 'package:nuitri_pilot_frontend/data/data.dart';

class AppendableListPanel extends StatefulWidget {
  final String tag;
  const AppendableListPanel({super.key, required this.tag});

  @override
  // ignore: no_logic_in_create_state
  State<AppendableListPanel> createState() =>
      // ignore: no_logic_in_create_state
      _AppendableListPanelState(tag: tag);
}

class _AppendableListPanelState extends State<AppendableListPanel> {
  late Future<WellnessCatagory?> _future;
  final String tag;

  _AppendableListPanelState({required this.tag});

  @override
  void initState() {
    super.initState();
    _future = DI.I.wellnessService.getWellnessCatagory(tag);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = DI.I.wellnessService.getWellnessCatagory(tag); // 重新拉取
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<WellnessCatagory?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Text('Loading data has error'),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _refresh,
                        child: const Text('Reload'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          final data = snap.data?.items ?? const [];
          if (data.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                _PlaceholderPanel(
                  title: "Chronic Conditions",
                  description: "No conditions yet. Pull to refresh or add new.",
                  icon: Icons.favorite_outline,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = data[i];
              return ListTile(
                title: Text(c.name),
                leading: const Icon(Icons.health_and_safety_outlined),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlaceholderPanel extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _PlaceholderPanel({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
