import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../social/presentation/pages/main_feed_screen.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/config/router/app_router.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';

class PatientDashboard extends StatefulWidget {
  final int userId;
  const PatientDashboard({super.key, required this.userId});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final caregivers = [
    {
      'name': 'Arnold Simpson',
      'status': 'Available',
      'lastSeen': '15 mins ago',
    },
    {'name': 'Ryan Simpson', 'status': 'Available', 'lastSeen': '25 mins ago'},
    {
      'name': 'Jackie Simpson',
      'status': 'Available',
      'lastSeen': '20 mins ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarHelper.createAppBar(context, title: 'Patient Dashboard'),
      drawer: const CommonDrawer(currentRoute: '/dashboard'),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final userName = userProvider.user?.name ?? 'Patient';
                    return Text(
                      'Good Morning !!!  $userName',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'How are you feeling today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: const [
                      EmojiLabel(emoji: '😡', label: 'Angry'),
                      EmojiLabel(emoji: '😐', label: 'Sad'),
                      EmojiLabel(emoji: '😫', label: 'Tired'),
                      EmojiLabel(emoji: '😨', label: 'Fearful'),
                      EmojiLabel(emoji: '😑', label: 'Neutral'),
                      EmojiLabel(emoji: '😊', label: 'Happy'),
                    ],
                  ),
                ),
                const Divider(height: 30, thickness: 2),
                Text(
                  'How is your pain today?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                    PainEmojiLabel(emoji: '😀', label: '1\nNo Pain'),
                    PainEmojiLabel(emoji: '🙂', label: '2\nMild'),
                    PainEmojiLabel(emoji: '😐', label: '3\nModerate'),
                    PainEmojiLabel(emoji: '😣', label: '4\nSevere'),
                    PainEmojiLabel(emoji: '😭', label: '5\nWorst Pain'),
                ),
                const Divider(height: 30, thickness: 2),
                ...caregivers.map(
                  (c) => CaregiverCard(
                    name: c['name']!,
                    status: c['status']!,
                    lastInteraction: c['lastSeen']!,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medication,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medication Tracker',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '3 medications scheduled today',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(context).dividerTheme.color ??
                            Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Diet Tracking',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Add today\'s meals',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmojiLabel extends StatelessWidget {
  final String emoji;
  final String label;

  const EmojiLabel({Key? key, required this.emoji, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).cardTheme.color ??
                  Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    Theme.of(context).dividerTheme.color ??
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class PainEmojiLabel extends StatelessWidget {
  final String emoji;
  final String label;

  const PainEmojiLabel({Key? key, required this.emoji, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class CaregiverCard extends StatelessWidget {
  final String name;
  final String status;
  final String lastInteraction;

  const CaregiverCard({
    Key? key,
    required this.name,
    required this.status,
    required this.lastInteraction,
  }) : super(key: key);
        side: BorderSide(
          color:
              Theme.of(context).dividerTheme.color ??
              Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
        ),
      ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Text(
                name.substring(0, 1),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status == 'Available'
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).disabledColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.videocam, size: 16),
                  label: const Text('Call'),
                ),
                const SizedBox(height: 4),
                Text(
                  lastInteraction,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
