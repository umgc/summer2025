class Course {
  final String id;
  final String name;

  Course({required this.id, required this.name});

  factory Course.fromJson(Map<String, dynamic> json) {
    try {
      return Course(
        id: json['id'] as String? ?? '0',
        name: json['name'] as String? ?? 'Untitled Course',
      );
    } catch (e) {
      print('Invalid course JSON: $json');
      rethrow;
    }
  }
}