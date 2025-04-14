import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import '../provider/connection_provider.dart';

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(connectionProvider);
    final notifier = ref.read(connectionProvider.notifier);
    if (state == null) {
      return const Scaffold(body: Center(child: Text('Error: Connection notifier is null')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('VPN Connection'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// lottie image when connecting
              state.isConnecting
                  ? Lottie.asset(
                'assets/loading.json',
                height: 20.h,
                fit: BoxFit.cover,
              )
                  : Icon(
                state.isConnected ? Icons.lock : Icons.lock_open,
                size: 30.sp,
                color: state.isConnected ? Colors.green : Colors.red,
              ),
              SizedBox(height: 4.h),
              /// Connection Button
              Text(
                state.isConnected
                    ? 'Connected: ${state.duration.inMinutes}m ${state.duration.inSeconds.remainder(60)}s'
                    : 'Disconnected',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500, // Explicit font weight
                ),
              ),
              SizedBox(height: 4.h),

              FilledButton(
                onPressed: notifier.toggleConnection,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 2.h,
                  ),
                  backgroundColor: state.isConnected ? Colors.red : Colors.blue,
                ),
                child: Text(
                  state.isConnected ? 'DISCONNECT' : 'CONNECT',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      /// Analystics History button
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/analyticsChart'),
        child: const Icon(Icons.analytics),
      ),
    );
  }
}