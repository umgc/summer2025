import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRoleProvider = StateProvider<String>((ref) => 'Trainee'); // default
final jwtTokenProvider = StateProvider<String?>((ref) => null);
