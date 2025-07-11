import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FamilyMemberCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String relationship;
  final String phone;
  final String email;
  final String lastInteraction;

  const FamilyMemberCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.lastInteraction,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green.shade700),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              relationship,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Phone button
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green, size: 20),
                  onPressed: () async {
                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  tooltip: 'Call $firstName',
                ),
                // SMS button
                IconButton(
                  icon: const Icon(Icons.message, color: Colors.blue, size: 20),
                  onPressed: () async {
                    final uri = Uri(scheme: 'sms', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  tooltip: 'Send SMS to $firstName',
                ),
                // Email button (show only if email is provided)
                if (email.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.email,
                      color: Colors.orange,
                      size: 20,
                    ),
                    onPressed: () async {
                      final uri = Uri(
                        scheme: 'mailto',
                        path: email,
                        queryParameters: {
                          'subject': 'CareConnect Family Update',
                          'body': 'Hello $firstName,\n\n',
                        },
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    tooltip: 'Email $firstName',
                  ),
              ],
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (email.isNotEmpty)
              Text(
                'Email: $email',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            Text('Last Interaction: $lastInteraction'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            switch (value) {
              case 'call':
                final uri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                break;
              case 'sms':
                final uri = Uri(scheme: 'sms', path: phone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
                break;
              case 'email':
                if (email.isNotEmpty) {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: email,
                    queryParameters: {
                      'subject': 'CareConnect Family Update',
                      'body': 'Hello $firstName,\n\n',
                    },
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                }
                break;
              case 'edit':
                // TODO: Implement edit functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit feature coming soon')),
                );
                break;
              case 'delete':
                // TODO: Implement delete functionality
                _showDeleteConfirmation(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Call'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sms',
              child: Row(
                children: [
                  Icon(Icons.message, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Send SMS'),
                ],
              ),
            ),
            if (email.isNotEmpty)
              const PopupMenuItem(
                value: 'email',
                child: Row(
                  children: [
                    Icon(Icons.email, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Send Email'),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Family Member'),
          content: Text(
            'Are you sure you want to remove $fullName from your family members?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement delete functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$fullName removed successfully')),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
