import 'dart:convert';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/friend_dto.dart';
import 'chat_room_screen.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int? _userId;
  List<FriendDto> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchFriends();
  }

  Future<void> _loadUserIdAndFetchFriends() async {
    final userIdStr = await _secureStorage.read(key: 'userId');
    if (userIdStr != null) {
      setState(() => _userId = int.tryParse(userIdStr));
      await fetchFriends();
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> fetchFriends() async {
    if (_userId == null) return;

    final url = Uri.parse(
      '${getBackendBaseUrl()}/v1/api/friends/list/$_userId',
    );
    final headers = await ApiService.getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        friends = data.map((json) => FriendDto.fromJson(json)).toList();
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
                  leading: const Icon(Icons.person),
                  title: Text(friend.name),
                  subtitle: Text(friend.email),
                  trailing: const Icon(Icons.chat),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                                peerUserId: friend.id,
                                peerName: friend.name
                            ),
                        ),
                    );
                  },
                );
              },
            )
    );
  }
}
