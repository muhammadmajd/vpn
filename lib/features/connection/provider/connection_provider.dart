import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vpn_app/features/analytics/models/analytics_model.dart';

import '../../analytics/repositories/analytics_repository.dart';
import '../model/connection_model.dart';

class ConnectionNotifier extends StateNotifier<VpnConnectionState> {
  final Ref _ref;
  Timer? _timer;
  bool get isTimerActive => _timer?.isActive ?? false;

  ConnectionNotifier(this._ref) : super(VpnConnectionState.initial()); // Initialize with the initial state
  Future<void> toggleConnection() async {
    if (state.isConnecting) return;

    state = state.copyWith(isConnecting: true);
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    state = state.copyWith(
      isConnected: !state.isConnected,
      isConnecting: false,
      lastConnection: now,
    );

    if (state.isConnected) {
      _startTimer();
    } else {
      _saveSession(now);
      _stopTimer();
    }
  }

  Future<void> toggleConnection_old() async {
    if (state.isConnecting) return;

    state = state.copyWith(isConnecting: true);
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    state = state.copyWith(
      isConnected: !state.isConnected,
      isConnecting: false,
      lastConnection: now,
    );

    if (state.isConnected) {
      _startTimer();
    } else {

      _saveSession(now);
      _stopTimer();
    }
  }


/// Save Session
  void _saveSession(DateTime startTime) {

    final session = VpnSession(
      startTime: startTime,
      duration: state.duration,  // This will automatically convert to seconds
    );
    _ref.read(analyticsRepositoryProvider).saveSession(session);
    state = state.copyWith(duration: Duration.zero);

  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        duration: state.duration + const Duration(seconds: 1),
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final connectionProvider = StateNotifierProvider<ConnectionNotifier, VpnConnectionState>((ref) {
  return ConnectionNotifier(ref);
});