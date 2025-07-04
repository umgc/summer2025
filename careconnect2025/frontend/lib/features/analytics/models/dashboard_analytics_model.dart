class DashboardAnalytics {
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double? adherenceRate;
  final double? avgHeartRate;
  final double? avgSpo2;
  final double? avgSystolic;
  final double? avgDiastolic;
  final double? avgWeight;

  DashboardAnalytics({
    this.periodStart,
    this.periodEnd,
    this.adherenceRate,
    this.avgHeartRate,
    this.avgSpo2,
    this.avgSystolic,
    this.avgDiastolic,
    this.avgWeight,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) =>
      DashboardAnalytics(
            periodStart: json['periodStart'] != null ? DateTime.parse(json['periodStart']) : null,
            periodEnd: json['periodEnd'] != null ? DateTime.parse(json['periodEnd']) : null,
            adherenceRate: json['adherenceRate']?.toDouble(),
            avgHeartRate: json['avgHeartRate']?.toDouble(),
            avgSpo2: json['avgSpo2']?.toDouble(),
            avgSystolic: json['avgSystolic']?.toDouble(),
            avgDiastolic: json['avgDiastolic']?.toDouble(),
            avgWeight: json['avgWeight']?.toDouble(),
      );
}

// Type alias to support the DashboardAnalyticsModel name used in other files
typedef DashboardAnalyticsModel = DashboardAnalytics;
