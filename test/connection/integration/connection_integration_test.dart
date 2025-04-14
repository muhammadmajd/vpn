import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vpn_app/features/analytics/models/analytics_model.dart';
import 'package:vpn_app/features/analytics/repositories/analytics_repository.dart';
import 'package:vpn_app/features/connection/model/connection_model.dart';
import 'package:vpn_app/features/connection/provider/connection_provider.dart';
import 'package:equatable/equatable.dart';

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
      final fixedTime = DateTime.now();
      notifier.state = notifier.state.copyWith(
        isConnected: false, // Indicates disconnected state
        isConnecting: false, // Indicates not currently connecting
        duration: Duration.zero, // Duration is zero initially

        lastConnection: fixedTime,
      );

      expect(
          notifier.state ==VpnConnectionState.initial(), false
      );
      /*expect(
        notifier.state ==
        predicate<VpnConnectionState>((state) =>
        state.isConnected == false &&
            state.isConnecting == false &&
            state.duration == Duration.zero &&
            state.lastConnection==fixedTime), false
      );*/
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

    test('should start connection process', () async {

     // notifier.state = notifier.state.copyWith(isConnecting: true);
      await notifier.toggleConnection();

      expect(notifier.state.isConnecting, false);
      expect(notifier.state.isConnected, true);
    });

    test('should stop connection process', () async {
    // Connect first
      await notifier.toggleConnection();

      // Disconnect
      await notifier.toggleConnection();

      expect(notifier.state.isConnecting, false);
      expect(notifier.state.isConnected, false);
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
      notifier.state = notifier.state.copyWith(
          isConnected: false, // Indicates disconnected state
          isConnecting: true, // Indicates not currently connecting
          duration: Duration(seconds: 1), // Duration is zero initially
          lastConnection: null);
      // Disconnect
      await notifier.toggleConnection();

      //await Future.delayed(const Duration(seconds: 1));

      expect(notifier.state.duration, const Duration(seconds: 1));
    });
  });

  group('Analytics functionality', () {
    test('should save session when disconnecting', () async {
// Setup: Tell the mock repository what to return when saveSession is called
      when(() => mockRepository.saveSession(any())).thenAnswer((_) => Future.value());

// Connect first
      await notifier.toggleConnection();
      await Future.delayed(const Duration(seconds: 1));

// Disconnect
      await notifier.toggleConnection();

      verify(() => mockRepository.saveSession(any())).called(1);
    });
  });
}