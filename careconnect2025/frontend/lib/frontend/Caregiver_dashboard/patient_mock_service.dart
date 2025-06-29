import 'patient_model.dart';

Future<List<Patient>> fetchPatientsForCaregiver(String caregiverEmail) async {
  await Future.delayed(Duration(seconds: 1)); // Simulate network delay

  //return [];
// }

  // Fake filter: return only if email matches // this needs to be connect with backend actual API to fetch actual data
  if (caregiverEmail == 'jane.malala@example.com') {
    return [
      Patient(name: 'Homer Simpson', age: 85, lastInteraction: '10 mins ago'),
      Patient(name: 'Marge Simpson', age: 83, lastInteraction: '30 mins ago'),
      Patient(name: 'Bart Simpson', age: 81, lastInteraction: '20 mins ago'),
    ];
  } else {
    return []; // No patients assigned to this caregiver
  }
}

