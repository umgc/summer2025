import 'dart:convert';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyFriendsScreen extends StatefulWidget {
  final int userId;
  const MyFriendsScreen({super.key, required this.userId});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  List<dynamic> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final url = Uri.parse(
      '{$getBackendBaseUrl()}/api/friends/list${widget.userId}',
    );
    final headers = await ApiService.getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      setState(() {
        friends = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load friends')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Friends")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? Center(child: Text("You have no friends yet."))
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(friend['name']),
                  subtitle: Text(friend['email']),
                );
              },
            ),
    );
  }
}
