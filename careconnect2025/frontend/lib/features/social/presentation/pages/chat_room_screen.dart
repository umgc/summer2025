import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatRoomScreen extends StatefulWidget {
  final int peerUserId;

  const ChatRoomScreen({super.key, required this.peerUserId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final FlutterSecureStorage _secureStorage =
      FlutterSecureStorage(); // ✅ New: SecureStorage instance
  int? _currentUserId; // ✅ New: No longer passed via constructor
  List<dynamic> messages = [];
  bool isLoading = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // ✅ New: Load userId from secure storage
  Future<void> _loadUserId() async {
    final idString = await _secureStorage.read(key: 'userId');
    if (idString != null) {
      setState(() => _currentUserId = int.tryParse(idString));
      fetchConversation(); // Now safe to call with loaded ID
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to load user ID')));
    }
  }

  Future<void> fetchConversation() async {
    if (_currentUserId == null) return;
    setState(() => isLoading = true);

    try {
      final convo = await ApiService.getConversation(
        user1: _currentUserId!,
        user2: widget.peerUserId,
      );
      setState(() {
        messages = convo;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load conversation: $e')),
      );
    }
  }

  Future<void> sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _currentUserId == null) return;

    try {
      await ApiService.sendMessage(
        senderId: _currentUserId!,
        receiverId: widget.peerUserId,
        content: content,
      );

      _controller.clear();
      await fetchConversation();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message')));
    }
  }

  Widget buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['senderId'] == _currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade100 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg['content'] ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final reversedIndex = messages.length - 1 - index;
                      return buildMessageBubble(messages[reversedIndex]);
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
