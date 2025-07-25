import 'package:care_connect_app/config/env_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/features/social/presentation/pages/my_friend_screen.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

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
    final url = Uri.parse(
      '${getBackendBaseUrl()}/api/friends/requests/${widget.userId}',
    );
    final response = await http
        .get(url)
        .timeout(
          const Duration(seconds: 180),
          onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
        );

    if (response.statusCode == 200) {
      setState(() {
        requests = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load requests')));
    }
  }

  Future<void> acceptRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('${getBackendBaseUrl()}/api/friends/accept'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request accepted')));
      fetchRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to accept request')));
    }
  }

  Future<void> rejectRequest(int requestId) async {
    final response = await http.post(
      Uri.parse('${getBackendBaseUrl()}/api/friends/reject'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request rejected')));
      fetchRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to reject request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'Friend Requests',
        additionalActions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'My Friends',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyFriendsScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const CommonDrawer(currentRoute: '/friend_requests'),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => acceptRequest(req['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => rejectRequest(req['id']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
