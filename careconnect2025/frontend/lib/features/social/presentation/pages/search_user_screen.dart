import 'dart:convert';

import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> results = [];
  bool isLoading = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final idStr = await _secureStorage.read(key: 'userId');
    if (idStr != null) {
      setState(() {
        _userId = int.tryParse(idStr);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> searchUsers() async {
    if (_userId == null) return;

    setState(() => isLoading = true);
    try {
      final response = await ApiService.searchUsers(
        _controller.text.trim(),
        _userId!,
      );

      if (response.statusCode == 200) {
        setState(() => results = jsonDecode(response.body));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Search failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isLoading = false);
  }

  Future<void> sendRequest(int toUserId) async {
    try {
      final response = await ApiService.sendFriendRequest(_userId!, toUserId);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Friend request sent')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search by name or email',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchUsers,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: ElevatedButton(
                          onPressed: () => sendRequest(user['id']),
                          child: Text('Add'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
