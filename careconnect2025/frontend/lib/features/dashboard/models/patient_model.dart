class Address {
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? zip;
  final String? phone;

  Address({
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.zip,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    line1: json['line1'],
    line2: json['line2'],
    city: json['city'],
    state: json['state'],
    zip: json['zip'],
    phone: json['phone'],
  );

  Map<String, dynamic> toJson() => {
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'zip': zip,
    'phone': phone,
  };
}

class Patient {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String dob;
  final String relationship;
  final String? profileImageUrl;
  final Address? address;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.relationship,
    this.profileImageUrl,
    this.address,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
    id: json['id'],
    firstName: json['firstName'] ?? '',
    lastName: json['lastName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    dob: json['dob'] ?? '',
    relationship: json['relationship'] ?? '',
    profileImageUrl: json['profileImageUrl'] ?? '',
    address: json['address'] != null ? Address.fromJson(json['address']) : null,
  );

  // adding teh getter to display
  // Getter for linkId - returns the patient ID (or another unique identifier)
  int get linkId => id;

  // Getter for calculating the patient's age from the 'dob' field
  int get age {
    DateTime birthDate = DateTime.parse(dob);
    DateTime now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years;
  }
}
