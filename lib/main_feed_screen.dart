import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:care_connect_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'new_post_screen.dart';
import 'comment_screen.dart';
import 'package:care_connect_app/widgets/user_avatar.dart';

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
      print('Feed status: ${response.statusCode}');
      print('Feed response: ${response.body}');

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
    final imageUrl = post['imageUrl'];
    final resolvedUrl = imageUrl != null && imageUrl.isNotEmpty
        ? (Platform.isAndroid
        ? 'http://10.0.2.2:3000$imageUrl'
        : 'http://localhost:3000$imageUrl')
        : null;

    return InkWell(
      onTap: () {
        if (post['id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommentScreen(postId: post['id']),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(imageUrl: post['profileImageUrl'], radius: 20),
                  const SizedBox(width: 10),
                  Text(
                    post['username'] ?? 'Unknown',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    post['timestamp'] ?? '',
                    style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(post['content'] ?? ''),
              if (resolvedUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    resolvedUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1),
              TextButton.icon(
                onPressed: () {
                  if (post['id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentScreen(postId: post['id']),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.comment, size: 18),
                label: Text('${post['commentCount'] ?? 0} comments'),
              )
            ],
          ),
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
            ? const Center(child: Text('No posts yet. Pull to refresh.'))
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return buildPostCard(posts[index]);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.edit),
        onPressed: () async {
          final success = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewPostScreen()),
          );
          if (success == true) {
            fetchFeed(); // Refresh feed after successful post
          }
        },
      ),
    );
  }
}
