import 'package:flutter/material.dart';
import 'package:care_connect_app/services/gamification_service.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'achievement_detail_screen.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  int level = 1;
  int xp = 0;
  int xpTarget = 50;
  List<Map<String, dynamic>> allAchievements = [];
  List<Map<String, dynamic>> earnedAchievements = [];
  bool isLoading = true;

  late ConfettiController _confettiController;
  int userId = 1;
  late SharedPreferences _prefs;
  int previousAchievementCount = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    initializePrefsAndLoad();
  }

  Future<void> initializePrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();
    userId =
        int.tryParse(_prefs.getString('userId') ?? '') ??
        1; // <-- Get dynamic userId here
    previousAchievementCount = _prefs.getInt('achievement_count') ?? 0;
    await loadGamificationData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> loadGamificationData() async {
    try {
      final progress = await GamificationService.fetchXPProgress(userId);
      final earned = await GamificationService.fetchAchievements(userId);
      final all = await GamificationService.fetchAllAchievements(userId);

      // Confetti trigger
      if (earned.length > previousAchievementCount) {
        _confettiController.play();
        previousAchievementCount = earned.length;
        await _prefs.setInt('achievement_count', earned.length);
      }

      List<Map<String, dynamic>> merged = (all).map<Map<String, dynamic>>((a) {
        final match = earned.firstWhere(
          (e) => e['title']?.toString().trim() == a['title']?.toString().trim(),
          orElse: () => {},
        );
        return {...a, 'unlocked': match != null};
      }).toList();

      setState(() {
        level = progress['level'];
        xp = progress['xp'];
        earnedAchievements = List<Map<String, dynamic>>.from(earned);
        allAchievements = merged;
        xpTarget = level * 50;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading gamification data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: const Text(
          'Care Connect',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AchievementDetailScreen(achievements: allAchievements),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Gamification',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Icon(Icons.shield, size: 80, color: Colors.indigo),
                      const SizedBox(height: 12),
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: xp / xpTarget,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blue.shade900,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$xp / $xpTarget XP',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: allAchievements.length,
                          itemBuilder: (context, index) {
                            final achievement = allAchievements[index];
                            return buildAchievement(achievement);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 25,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.3,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAchievement(Map<String, dynamic> achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AchievementDetailScreen(
                achievements: allAchievements,
              ), // ✅ This must include the `unlocked` key
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                achievement['title'] ?? 'Unnamed Achievement',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: achievement['unlocked'] == true
                    ? Colors.green.shade300
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                achievement['unlocked'] == true
                    ? Icons.check
                    : Icons.lock_outline,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
