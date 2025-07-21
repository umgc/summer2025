import 'dart:convert';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/features/social/presentation/pages/my_friend_screen.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int? _userId;

  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndRequests();
  }

  Future<void> _loadUserIdAndRequests() async {
    final userIdString = await _secureStorage.read(
      key: 'userId',
    ); //Read from secure storage
    if (userIdString != null) {
      setState(
        () => _userId = int.tryParse(userIdString),
      ); //Parse and save to state
      fetchRequests(); //Continue fetching now that userId is available
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> fetchRequests() async {
    if (_userId == null) return;

    setState(() => isLoading = true);
    final url = Uri.parse(
      '${getBackendBaseUrl()}/v1/api/friends/requests/$_userId',
    );
    final headers = await ApiService.getAuthHeaders();
    final response = await http.get(url, headers: headers);

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
    final url = Uri.parse('${getBackendBaseUrl()}/v1/api/friends/accept');
    final headers = await ApiService.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request accepted')));
      fetchRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to accept request')));
    }
  }

  Future<void> rejectRequest(int requestId) async {
    final url = Uri.parse('${getBackendBaseUrl()}/v1/api/friends/reject');
    final headers = await ApiService.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request rejected')));
      fetchRequests();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to reject request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        backgroundColor: Colors.blue.shade900,
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
