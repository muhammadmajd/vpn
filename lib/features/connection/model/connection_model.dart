import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'connection_model.g.dart';

@HiveType(typeId: 0)
class VpnConnectionState  extends Equatable{
  @HiveField(0) final bool isConnected;
  @HiveField(1) final bool isConnecting;
  @HiveField(2) final Duration duration;
  @HiveField(3) final DateTime? lastConnection;

  const VpnConnectionState({
    required this.isConnected,
    required this.isConnecting,
    required this.duration,
    this.lastConnection,
  });
  @override
  List<Object?> get props => [
    isConnected,
    isConnecting,
    duration,
    lastConnection,
  ];

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;
    return other is VpnConnectionState &&
        other.isConnected == isConnected &&
        other.isConnecting == isConnecting &&
        other.duration == duration &&
        other.lastConnection==lastConnection
        ; // Allow small difference
  }
  // Factory constructor for initial state
  factory VpnConnectionState.initial() {
    return VpnConnectionState(
      isConnected: false, // Indicates disconnected state
      isConnecting: false, // Indicates not currently connecting
      duration: Duration.zero, // Duration is zero initially
      lastConnection: DateTime.now(), // Set to current time for reference
    );
  }

  VpnConnectionState copyWith({
    bool? isConnected,
    bool? isConnecting,
    Duration? duration,
    DateTime? lastConnection,
  }) {
    return VpnConnectionState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      duration: duration ?? this.duration,
      lastConnection: lastConnection ?? this.lastConnection,
    );
  }





}