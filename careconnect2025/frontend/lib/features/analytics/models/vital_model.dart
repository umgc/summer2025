class Vital {
  final int patientId;
  final DateTime timestamp;
  final double heartRate;
  final double spo2;
  final int systolic;
  final int diastolic;
  final double weight;

  Vital({
    required this.patientId,
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.systolic,
    required this.diastolic,
    required this.weight,
  });

  factory Vital.fromJson(Map<String, dynamic> json) => Vital(
        patientId: json['patientId'],
        timestamp: DateTime.parse(json['timestamp']),
        heartRate: (json['heartRate'] as num).toDouble(),
        spo2: (json['spo2'] as num).toDouble(),
        systolic: json['systolic'],
        diastolic: json['diastolic'],
        weight: (json['weight'] as num).toDouble(),
      );
}