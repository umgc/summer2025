class Vital {
  final DateTime timestamp;
  final double heartRate;
  final double spo2;
  final int systolic;
  final int diastolic;
  final double weight;
  final int? moodValue;
  final int? painValue;
  final int patientId;

  Vital({
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.systolic,
    required this.diastolic,
    required this.weight,
    required this.patientId,
    this.moodValue,
    this.painValue,
  });

  factory Vital.fromJson(Map<String, dynamic> json) {
    return Vital(
      patientId: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: (json['heartRate'] as num).toDouble(),
      spo2: (json['spo2'] as num).toDouble(),
      systolic: json['systolic'] as int,
      diastolic: json['diastolic'] as int,
      weight: (json['weight'] as num).toDouble(),
      moodValue: json['moodValue'] as int?,
      painValue: json['painValue'] as int?,
    );
  }
}
