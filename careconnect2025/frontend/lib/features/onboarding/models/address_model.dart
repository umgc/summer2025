class Address {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String zip;
  final String phone;

  Address({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.zip,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null && line2!.isNotEmpty) 'line2': line2,
      'city': city,
      'state': state,
      'zip': zip,
      'phone': phone,
    };
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      zip: json['zip'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}
