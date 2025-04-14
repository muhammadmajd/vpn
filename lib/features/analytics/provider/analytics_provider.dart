import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsState {
  final List<VpnSession> sessions;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    required this.sessions,
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    List<VpnSession>? sessions,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsNotifier(this.repository) : super(AnalyticsState(sessions: []));

  Future<void> loadSessions() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final sessions = await Future.value(repository.getSessions());
      state = state.copyWith(sessions: sessions, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return AnalyticsNotifier(repository);
});