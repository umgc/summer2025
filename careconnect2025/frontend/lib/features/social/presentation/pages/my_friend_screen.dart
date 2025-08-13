import 'dart:convert';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../../providers/user_provider.dart';
import '../model/friend_dto.dart';
import 'chat_room_screen.dart';

class MyFriendsScreen extends StatefulWidget {
  const MyFriendsScreen({super.key});

  @override
  State<MyFriendsScreen> createState() => _MyFriendsScreenState();
}

class _MyFriendsScreenState extends State<MyFriendsScreen> {
  List<FriendDto> friends = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() => isLoading = false);
        return;
      }
      fetchFriends(user.id);
    });
  }


  Future<void> fetchFriends(int userId) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      '${getBackendBaseUrl()}/v1/api/friends/list/$userId',
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
