// lib/widgets/user_avatar.dart
import 'package:flutter/material.dart';
import 'dart:io';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = (imageUrl != null && imageUrl!.isNotEmpty)
        ? (Platform.isAndroid
        ? 'http://10.0.2.2:3000$imageUrl'
        : 'http://localhost:3000$imageUrl')
        : null;

    return CircleAvatar(
      radius: radius,
      backgroundImage: resolvedUrl != null ? NetworkImage(resolvedUrl) : null,
      child: resolvedUrl == null ? const Icon(Icons.person, size: 20) : null,
    );
  }
}
