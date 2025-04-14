import 'package:flutter_test/flutter_test.dart';
import 'package:vpn_app/features/connection/model/connection_model.dart';

void main() {
  group('VpnConnectionState', () {
    test('initial state has correct default values', () {
      final state = VpnConnectionState.initial();

      expect(state.isConnected, false);
      expect(state.isConnecting, false);
      expect(state.duration, Duration.zero);
      expect(state.lastConnection, isNull);
    });

    test('constructor sets values correctly', () {
      final now = DateTime.now();
      const testDuration = Duration(seconds: 30);
      final state = VpnConnectionState(
        isConnected: true,
        isConnecting: false,
        duration: testDuration,
        lastConnection: now,
      );

      expect(state.isConnected, true);
      expect(state.isConnecting, false);
      expect(state.duration, testDuration);
      expect(state.lastConnection, now);
    });

    test('duration is stored and retrieved correctly', () {
      const durations = [
        Duration.zero,
        Duration(seconds: 1),
        Duration(minutes: 5),
        Duration(hours: 2),
      ];

      for (final duration in durations) {
        final state = VpnConnectionState(
          isConnected: true,
          isConnecting: false,
          duration: duration,
        );

        expect(state.duration, duration);
      }
    });




  });
}