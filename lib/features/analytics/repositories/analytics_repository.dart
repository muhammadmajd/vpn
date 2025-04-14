import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/analytics_model.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  throw UnimplementedError('Override in main.dart');
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});


class AnalyticsRepository {
  final Box<VpnSession> sessionsBox;  // Changed from 'box' to 'sessionsBox'
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  AnalyticsRepository(this.sessionsBox);  // Updated parameter name

  List<VpnSession> getSessionsOld() {
    return sessionsBox.values.toList().reversed.toList();  // Newest first
  }

  List<VpnSession> getSessions() {
    return sessionsBox.values.map((session) {
      return VpnSession(
        startTime: session.startTime,
        duration: session.duration, // Uses the getter
      );
    }).toList().reversed.toList();
  }

  Future<void> saveSessionOld(VpnSession session) async {
    await sessionsBox.add(session);
    await _analytics.logEvent(
      name: 'vpn_session',
      parameters: {
        'start_time': session.startTime.toIso8601String(),
        'duration_seconds': session.duration.inSeconds,
        'event_time': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> saveSession(VpnSession session) async {
    await sessionsBox.add(session);
    ///
    await _analytics.logEvent(
      name: 'vpn_session',
      parameters: {
        'start_time': session.startTime.toIso8601String(),
        'duration_seconds': session.durationSeconds,  // Use the int value
      },
    );
  }

  Future<void> clearSessions() async {
    await sessionsBox.clear();
  }
}