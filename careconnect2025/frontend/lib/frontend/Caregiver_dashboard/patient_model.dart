class Patient {
  final String name;
  final int age;
  final String lastInteraction;

  Patient({
    required this.name,
    required this.age,
    required this.lastInteraction,
  });

  factory Patient.fromJson(Map<String, dynamic> json) { //factory constructor can return different types
    return Patient(
      name: json['name'],
      age: json['age'],
      lastInteraction: json['lastInteraction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'lastInteraction': lastInteraction,
    };
  }
}
