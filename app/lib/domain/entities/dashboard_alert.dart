// lib/domain/entities/dashboard_alert.dart
enum AlertSeverity { info, warning, critical }

class DashboardAlert {
  final String        id;
  final String        message;
  final AlertSeverity severity;
  final DateTime      createdAt;

  const DashboardAlert({
    required this.id,
    required this.message,
    required this.severity,
    required this.createdAt,
  });
}