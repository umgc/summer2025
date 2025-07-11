class Course {
  final int id;
  final String fullName;

  Course({required this.id, required this.fullName});

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        id: json['id'] as int? ?? 0,
        fullName: json['fullname'] as String? ?? 'Untitled Course',
      );
    } catch (e) {
      print('Invalid course JSON: $json');
      rethrow;
    }
  }
}