import 'package:care_connect_app/config/env_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

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
    final response = await http.get(
      Uri.parse('${getBackendBaseUrl()}/api/friends/list/${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        friends = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load friends')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(context, title: 'My Friends'),
      drawer: const CommonDrawer(currentRoute: '/my_friends'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.isEmpty
          ? const Center(child: Text("You have no friends yet."))
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(friend['name']),
                  subtitle: Text(friend['email']),
                );
              },
            ),
    );
  }
}
