import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpn_app/firebase_options.dart' show DefaultFirebaseOptions;
import 'app.dart';
import 'features/analytics/repositories/analytics_repository.dart';
import 'features/analytics/models/analytics_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(VpnSessionAdapter());

  // Open the box with explicit type
  final Box<VpnSession> sessionsBox = await Hive.openBox<VpnSession>('vpn_sessions');

  runApp(
    ProviderScope(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(
          AnalyticsRepository(sessionsBox), // Now types match exactly
        ),
      ],
      child: const MyApp(),
    ),
  );
}