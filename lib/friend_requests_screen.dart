import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class FriendRequestsScreen extends StatefulWidget {
  final int userId;
  const FriendRequestsScreen({super.key, required this.userId});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() => isLoading = true);
    final url = Uri.parse('http://localhost:3000/friends/requests/${widget.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        requests = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load requests')));
    }
  }

  Future<void> acceptRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/friends/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request accepted')));
      fetchRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final req = requests[index];
          return ListTile(
            title: Text(req['from_username'] ?? 'Unknown'),
            subtitle: Text('Request ID: ${req['id']}'),
            trailing: ElevatedButton(
              onPressed: () => acceptRequest(req['id']),
              child: const Text('Accept'),
            ),
          );
        },
      ),
    );
  }
}