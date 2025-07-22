// lib/shared/widgets/user_avatar.dart
import '../../config/env_constant.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const UserAvatar({super.key, required this.imageUrl, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? resolvedUrl;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Check if it's already a complete URL
      if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
        resolvedUrl = imageUrl;
      } else {
        // It's a relative path, prepend the base URL
        resolvedUrl = '${getBackendBaseUrl()}$imageUrl';
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      backgroundImage: resolvedUrl != null ? NetworkImage(resolvedUrl) : null,
      child: resolvedUrl == null
          ? Icon(
              Icons.person,
              size: radius * 0.8,
              color: theme.colorScheme.primary,
            )
          : null,
    );
  }
}
