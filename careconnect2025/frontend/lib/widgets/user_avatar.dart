// lib/widgets/user_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    String? resolvedUrl;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Use kIsWeb to check for web, otherwise assume mobile/emulator
      if (kIsWeb) {
        resolvedUrl = 'http://localhost:8080$imageUrl';
      } else {
        resolvedUrl = 'http://10.0.2.2:8080$imageUrl';
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: resolvedUrl != null ? NetworkImage(resolvedUrl) : null,
      child: resolvedUrl == null ? const Icon(Icons.person, size: 20) : null,
    );
  }
}
