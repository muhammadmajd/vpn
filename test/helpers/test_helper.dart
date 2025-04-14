import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vpn_app/features/connection/model/connection_model.dart';
import 'package:vpn_app/features/connection/provider/connection_provider.dart';
import 'package:vpn_app/features/connection/screens/connection_screen.dart';
class MockRef extends Mock implements Ref {}

Widget createTestableWidget(WidgetTester tester, VpnConnectionState state) {
  final mockRef = MockRef();
  return Sizer(
    builder: (context, orientation, deviceType) {
      return ProviderScope(
        overrides: [
          connectionProvider.overrideWith((ref) {
            final notifier = ConnectionNotifier(mockRef);
            notifier.state = state; // Set the state for the notifier
            return notifier;
          }),
        ],
        child: MaterialApp(
          home: const ConnectionScreen(),
        ),
      );
    },
  );
}