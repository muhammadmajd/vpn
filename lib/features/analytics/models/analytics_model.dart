import 'package:hive/hive.dart';

part 'analytics_model.g.dart';

@HiveType(typeId: 1)
class VpnSession {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final int durationSeconds; // Store as int instead of Duration

  VpnSession({
    required this.startTime,
    required Duration duration, // Still accept Duration in constructor
  }) : durationSeconds = duration.inSeconds;

  // Add getter for convenience
  Duration get duration => Duration(seconds: durationSeconds);

  @override
  String toString() {
    return 'VpnSession(startTime: $startTime, duration: ${duration.inSeconds}s)';
  }
}