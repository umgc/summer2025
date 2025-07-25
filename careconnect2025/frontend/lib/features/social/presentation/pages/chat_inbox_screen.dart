import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../model/conversation_preview_dto.dart';
import 'chat_room_screen.dart';
import 'my_friend_screen.dart';


class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int? _userId;
  List<ConversationPreviewDto> inbox = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userIdString = await _secureStorage.read(key: 'userId');
    if (userIdString != null) {
      setState(() => _userId = int.tryParse(userIdString));
      fetchInbox();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> fetchInbox() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getInbox(_userId!);
      setState(() {
        inbox = (data as List)
            .map((json) => ConversationPreviewDto.fromJson(json))
            .toList();;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load inbox: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Messages'),
          actions: [
      IconButton(
      icon: const Icon(Icons.group),
      tooltip: 'My Friends',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MyFriendsScreen()),
        );
        },
      ),
          ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : inbox.isEmpty
          ? const Center(child: Text('No messages yet'))
          : ListView.builder(
              itemCount: inbox.length,
              itemBuilder: (context, index) {
                final convo = inbox[index];
                return ListTile(
                  title: Text(convo.peerName),
                  subtitle: Text(convo.content),
                  trailing: Text(
                    convo.timestamp.toIso8601String().split('T').join(' • '),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ChatRoomScreen(
                                peerUserId: convo.peerId,
                                peerName: convo.peerName,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
