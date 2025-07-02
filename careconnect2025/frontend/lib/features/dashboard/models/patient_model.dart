class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String relationship;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.relationship,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'],
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        dob: json['dob'] ?? '',
        relationship: json['relationship'] ?? '',
      );
}