import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vpn_app/features/analytics/provider/analytics_provider.dart';

import '../models/analytics_model.dart';

class AnalyticsChartScreen extends ConsumerStatefulWidget {
  const AnalyticsChartScreen({super.key});

  @override
  ConsumerState<AnalyticsChartScreen> createState() => _AnalyticsChartcreenState();
}

class _AnalyticsChartcreenState extends ConsumerState<AnalyticsChartScreen> {
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(analyticsProvider.notifier).loadSessions();
    });
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
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.sessions.isEmpty
          ? const Center(child: Text('No connection history available'))
          : Column(
        children: [
          const SizedBox(height: 20),
          /// Chart for connection history
          _buildPieChart(state.sessions),
          const SizedBox(height: 20),
          /// ListView for connection history
          Expanded(
            child: _buildSessionList(state.sessions),
          ),
        ],
      ),
    );
  }
  /// Chart for connection history
  Widget _buildPieChart(List<VpnSession> sessions) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: _buildSections(sessions),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<VpnSession> sessions) {
    return List.generate(sessions.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final session = sessions[i];
      final durationSec = session.duration.inSeconds;

      return PieChartSectionData(
        color: _getSessionColor(i),
        value: durationSec.toDouble(),
        title: durationSec > 10 ? '${durationSec}s' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _buildBadge(session, i),
        badgePositionPercentageOffset: 0.98,
      );
    });
  }

  Widget _buildBadge(VpnSession session, int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _getSessionColor(index), width: 2),
      ),
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: _getSessionColor(index),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSessionList(List<VpnSession> sessions) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: touchedIndex == index ? _getSessionColor(index).withOpacity(0.2) : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getSessionColor(index),
              child: Text('${index + 1}'),
            ),
            title: Text('Session ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMd().add_jm().format(session.startTime)),
                Text('Duration: ${session.duration.inSeconds}s'),
              ],
            ),
            trailing: Icon(
              Icons.timer,
              color: _getSessionColor(index),
            ),
          ),
        );
      },
    );
  }

  Color _getSessionColor(int index) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.amberAccent,
      Colors.lightBlueAccent,
    ];
    return colors[index % colors.length];
  }
}