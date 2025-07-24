/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../widgets/ai_chat.dart';
import '../../../../widgets/family_member_card.dart';
import '../../../../widgets/add_family_member_dialog.dart';

class PatientDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CareConnect", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, size: 40),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSection(),
            SizedBox(height: 40),
            _buildCallButton(context),
            SizedBox(height: 40),
            _buildFamilyMembersSection(),
            SizedBox(height: 40),
            _buildAIChatSection(),
          ],
        ),
      ),
    );
  }

  // Hamburger Menu with Simple Labels
  void _showMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Menu', style: TextStyle(fontSize: 24)),
          children: [
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to some other screen if needed
              },
              child: Text('Home', style: TextStyle(fontSize: 20)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to settings if needed
              },
              child: Text('Settings', style: TextStyle(fontSize: 20)),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to help
              },
              child: Text('Help', style: TextStyle(fontSize: 20)),
            ),
          ],
        );
      },
    );
  }

  // Drawer Menu for Navigation
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('CareConnect', style: TextStyle(fontSize: 30, color: Colors.white)),
          ),
          ListTile(
            leading: Icon(Icons.home, size: 30),
            title: Text('Home', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, size: 30),
            title: Text('Settings', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.help, size: 30),
            title: Text('Help', style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Rating Section (Updated 1-10 Emoji Ratings)
  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How are you feeling today?', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(10, (index) {
            return GestureDetector(
              onTap: () {
                // Handle rating logic (index + 1)
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  _getEmojiForRating(index + 1),
                  style: TextStyle(fontSize: 40),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Emoji for Rating (1-10)
  String _getEmojiForRating(int rating) {
    switch (rating) {
      case 1:
        return '😞';
      case 2:
        return '😔';
      case 3:
        return '😕';
      case 4:
        return '😐';
      case 5:
        return '🙂';
      case 6:
        return '😊';
      case 7:
        return '😀';
      case 8:
        return '😁';
      case 9:
        return '😂';
      case 10:
        return '😍';
      default:
        return '😐';
    }
  }

  // Call Button Section (Navigates to Patient Call Screen)
  Widget _buildCallButton(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to Patient Call Screen
          context.push('/patient_call_screen'); // Assuming '/patient_call_screen' route exists
        },
        icon: Icon(Icons.phone, size: 30),
        label: Text(
          'Make a Call',
          style: TextStyle(fontSize: 22),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40), backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: Size(200, 60),
        ),
      ),
    );
  }

  // Family Members Section (Simplified)
  Widget _buildFamilyMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family Members', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        FamilyMemberCard(firstName: '',lastName: '',relationship: '',phone: '', email: '', lastInteraction: '',), // Replace with your family member card widget
      ],
    );
  }

  // AI Chat Section (Simplified)
  Widget _buildAIChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Chat', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        AIChat(role: '',), // Replace with your AI chat widget
      ],
    );
  }
}
*/

