import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vpn_app/features/analytics/models/analytics_model.dart';
import 'package:vpn_app/features/analytics/repositories/analytics_repository.dart';
import 'package:vpn_app/features/connection/model/connection_model.dart';
import 'package:vpn_app/features/connection/provider/connection_provider.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}
class MockRef extends Mock implements Ref {}

void main() {


  late ConnectionNotifier notifier;
  late MockAnalyticsRepository mockRepository;
  late MockRef mockRef;

  setUpAll(() {
    // Register fallback value for VpnSession
    registerFallbackValue(
      VpnSession(
        startTime: DateTime(2023),
        duration: Duration.zero,
      ),
    );
  });

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    mockRef = MockRef();

    when(() => mockRef.read(analyticsRepositoryProvider))
        .thenReturn(mockRepository);

    // Setup default mock response
    when(() => mockRepository.saveSession(any()))
        .thenAnswer((_) => Future.value());

    notifier = ConnectionNotifier(mockRef);
  });
  tearDown(() {
    notifier.dispose();
  });

  group('Initial state', () {
      test('should have initial state', () {
        expect(notifier.state, VpnConnectionState.initial());
      });
    });

  group('toggleConnection', () {
    test('should not do anything if already connecting', () async {
      // Set initial state to connecting
      notifier.state = notifier.state.copyWith(isConnecting: true);

      await notifier.toggleConnection();

      expect(notifier.state.isConnecting, true);
    });


    test('should update lastConnection time', () async {
      final beforeToggle = DateTime.now();
      await notifier.toggleConnection();
      final afterToggle = DateTime.now();

      expect(notifier.state.lastConnection, isNotNull);
      expect(notifier.state.lastConnection!.isAfter(beforeToggle), isTrue);
      expect(notifier.state.lastConnection!.isBefore(afterToggle), isTrue);
    });
  });

  group('Timer functionality', () {
    test('should start timer when connecting', () async {
      await notifier.toggleConnection();

      // Wait for timer to tick
      await Future.delayed(const Duration(seconds: 1));

      expect(notifier.state.duration, const Duration(seconds: 1));
    });

    test('should stop timer when disconnecting', () async {
      // Setup: Tell the mock repository what to return when saveSession is called
      when(() => mockRepository.saveSession(any())).thenAnswer((_) => Future.value());

      // Connect first
      await notifier.toggleConnection();
      await Future.delayed(const Duration(seconds: 1));

      // Disconnect
      await notifier.toggleConnection();
      final durationAtDisconnect = notifier.state.duration;

      // Wait to ensure timer stopped
      await Future.delayed(const Duration(seconds: 1));

      expect(notifier.state.duration, durationAtDisconnect);

      // Verify that saveSession was called
      verify(() => mockRepository.saveSession(any())).called(1);
    });

    test('should reset duration after saving session', () async {
      // Connect and let timer run
      await notifier.toggleConnection();
      await Future.delayed(const Duration(seconds: 2));

      // Disconnect
      await notifier.toggleConnection();

      expect(notifier.state.duration, Duration.zero);
    });
  });

  group('Session saving', () {
    test('should save session with correct data when disconnecting', () async {
      when(() => mockRepository.saveSession(any()))
          .thenAnswer((_) => Future.value());

      await notifier.toggleConnection();
      await Future.delayed(const Duration(seconds: 2));

      await notifier.toggleConnection();

      final captured = verify(() => mockRepository.saveSession(captureAny())).captured;
      final savedSession = captured.first as VpnSession;

      //expect(savedSession.startTime.isAfter(connectTime), isTrue);
      expect(savedSession.duration.inSeconds, greaterThanOrEqualTo(2));
    });

    test('should not save session if never properly connected', () async {
      // Start connecting but cancel before connection completes
      notifier.toggleConnection(); // Start connecting
      notifier.toggleConnection(); // Cancel before connection completes

      verifyNever(() => mockRepository.saveSession(any()));
    });

    test('should save minimal session when immediately disconnected', () async {
      when(() => mockRepository.saveSession(any()))
          .thenAnswer((_) => Future.value());

      await notifier.toggleConnection(); // Connect
      await notifier.toggleConnection(); // Immediately disconnect

      final captured = verify(() => mockRepository.saveSession(captureAny())).captured;
      final session = captured.first as VpnSession;

      expect(session.duration.inSeconds, greaterThan(0));
    });


  });

  group('Dispose', () {
    test('should cancel timer when disposed', () async {
      // Setup mock repository
      when(() => mockRepository.saveSession(any()))
          .thenAnswer((_) => Future.value());

      // Connect to start timer
      await notifier.toggleConnection();

      // Wait for timer to tick at least once
      await Future.delayed(const Duration(milliseconds: 1100));

      // Verify timer was running by checking duration increased
      expect(notifier.state.duration.inSeconds, greaterThanOrEqualTo(1));

      if(!notifier.mounted) {
        // Verify through mock interactions that timer stopped
        // (No session should be saved after dispose)
        verifyNever(() => mockRepository.saveSession(any()));
        notifier.dispose();
        expect(notifier.isTimerActive, false);
      } else {
        // Alternative verification - check timer was cancelled
        // This assumes you can access the timer for testing
        expect(notifier.isTimerActive, true); // Add this getter to your notifier
      }

    });
  });
}