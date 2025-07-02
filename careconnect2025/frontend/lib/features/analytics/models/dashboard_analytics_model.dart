
class DashboardAnalytics {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double adherenceRate;
  final double avgHeartRate;
  final double avgSpo2;
  final double avgSystolic;
  final double avgDiastolic;
  final double avgWeight;

  DashboardAnalytics({
    required this.periodStart,
    required this.periodEnd,
    required this.adherenceRate,
    required this.avgHeartRate,
    required this.avgSpo2,
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgWeight,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) => DashboardAnalytics(
        periodStart: DateTime.parse(json['periodStart']),
        periodEnd: DateTime.parse(json['periodEnd']),
        adherenceRate: (json['adherenceRate'] as num).toDouble(),
        avgHeartRate: (json['avgHeartRate'] as num).toDouble(),
        avgSpo2: (json['avgSpo2'] as num).toDouble(),
        avgSystolic: (json['avgSystolic'] as num).toDouble(),
        avgDiastolic: (json['avgDiastolic'] as num).toDouble(),
        avgWeight: (json['avgWeight'] as num).toDouble(),
      );
}