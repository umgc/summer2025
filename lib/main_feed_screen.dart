import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';
import 'package:http/http.dart' as http;

class MainFeedScreen extends StatefulWidget {
  final int userId;
  const MainFeedScreen({super.key, required this.userId});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    setState(() => isLoading = true);

    try {
      final http.Response response = await ApiService.getFeed(widget.userId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts = data['feed'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load feed')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: post['profileImageUrl'] != null && post['profileImageUrl'].isNotEmpty
              ? NetworkImage(post['profileImageUrl'])
              : null,
          child: post['profileImageUrl'] == null || post['profileImageUrl'].isEmpty
              ? const Icon(Icons.person)
              : null,
        ),
        title: Text(post['username'] ?? 'Unknown User'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post['content'] ?? ''),
            const SizedBox(height: 4),
            Text(
              post['timestamp'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feed'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchFeed,
        child: posts.isEmpty
            ? const Center(child: Text('No posts yet.'))
            : ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return buildPostCard(posts[index]);
          },
        ),
      ),
    );
  }
}
