import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'features/analytics/screens/analysics_chart_screen.dart';
import 'features/connection/screens/connection_screen.dart';
import 'features/analytics/screens/analytics_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'VPN App',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const ConnectionScreen(),
          routes: {
            '/analytics': (context) => const AnalyticsScreen(),
            '/analyticsChart': (context) => const AnalyticsChartScreen(),
          },
        );
      },
    );
  }
}