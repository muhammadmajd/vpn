import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:vpn_app/features/connection/model/connection_model.dart';
import 'package:vpn_app/features/connection/provider/connection_provider.dart';
import 'package:vpn_app/features/connection/screens/connection_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helper.dart';



// Mock class for Ref


void main() {
  group('ConnectionScreen Widget Tests', () {
    testWidgets('renders initial disconnected state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(tester, VpnConnectionState.initial()));

// Verify initial UI
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.text('CONNECT'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows connected state when connected', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestableWidget(
          tester,
          VpnConnectionState(
            isConnected: true,
            isConnecting: false,
            duration: const Duration(minutes: 1, seconds: 5),
            lastConnection: DateTime.now(),
          ),
        ),
      );

// Verify connected UI
      expect(find.text('Connected: 1m 5s'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('DISCONNECT'), findsOneWidget);
    });

    testWidgets('calls toggleConnection when button is pressed', (WidgetTester tester) async {
// Create a mock Ref instance
      final mockRef = MockRef();
// Initialize the ConnectionNotifier with a disconnected state
      final connectionNotifier = ConnectionNotifier(mockRef);

      await tester.pumpWidget(
        createTestableWidget(
          tester,
          connectionNotifier.state, // Initial state of the notifier
        ),
      );

// Initialize the notifier state to be disconnected
      connectionNotifier.state = VpnConnectionState(
        isConnected: false,
        isConnecting: false, // Ensure it starts as not connecting
        duration: Duration.zero,
        lastConnection: DateTime.now(),
      );

// Tap the connection button
      await tester.tap(find.text('CONNECT'));
      await tester.pumpAndSettle(); // Allow time for the state to settle

// Check the state after toggling the connection
      expect(find.text('Connected: 0m 0s'), findsOneWidget); // Check for connected state
      expect(find.text('DISCONNECT'), findsOneWidget); // Check the button text by its disabled state
    });

    testWidgets('navigates to analytics when FAB is pressed', (WidgetTester tester) async {
// Create the testable widget with the initial state
      await tester.pumpWidget(
        createTestableWidget(
          tester,
          VpnConnectionState.initial(), // Default disconnected state
        ),
      );

// Define the routes for navigation directly in testable widget to ensure they are available
      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) {
            return ProviderScope(
              overrides: [
                connectionProvider.overrideWith((ref) => ConnectionNotifier(MockRef())),
              ],
              child: MaterialApp(
                home: const ConnectionScreen(),
                routes: {
                  '/analyticsChart': (_) => const Scaffold(body: Text('Analytics Page')),
                },
              ),
            );
          },
        ),
      );

// Simulate tapping the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(); // Allow time for the navigation to complete

// Verify the navigation to the analytics page
      expect(find.text('Analytics Page'), findsOneWidget);
    });
  });
}