import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';

class SearchUserScreen extends StatefulWidget {
  final int userId;
  const SearchUserScreen({super.key, required this.userId});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> results = [];
  bool isLoading = false;

  Future<void> searchUsers() async {
    setState(() => isLoading = true);
    try{
      final response = await ApiService.searchUsers(
      _controller.text.trim(),
      widget.userId,
    );

    if (response.statusCode == 200) {
      setState(() => results = jsonDecode(response.body));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed')));
    }
    } catch(e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'))
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> sendRequest(int toUserId) async {
    try{
    final response = await ApiService.sendFriendRequest(
      widget.userId,
      toUserId,
    );
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Friend request sent')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request failed')));
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
