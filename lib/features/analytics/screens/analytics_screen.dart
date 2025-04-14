import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vpn_app/features/analytics/provider/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(analyticsProvider.notifier).loadSessions());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(analyticsProvider.notifier).loadSessions(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(AnalyticsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.sessions.isEmpty) {
      return const Center(child: Text('No connection history available'));
    }

    return ListView.builder(
      itemCount: state.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text('Session ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMd().add_jm().format(session.startTime)),
                Text(
                  'Duration: ${session.duration.inMinutes}m '
                      '${session.duration.inSeconds.remainder(60)}s',
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward),
          ),
        );
      },
    );
  }
}