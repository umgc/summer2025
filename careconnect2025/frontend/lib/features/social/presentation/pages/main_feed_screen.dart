import 'dart:convert';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:care_connect_app/shared/widgets/user_avatar.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/post_with_comment_count_dto.dart';

import 'chat_inbox_screen.dart';
import 'comment_screen.dart';
import 'friend_requests_screen.dart';
import 'new_post_screen.dart';
import 'search_user_screen.dart';

class MainFeedScreen extends StatefulWidget {
  final int userId;
  const MainFeedScreen({super.key, required this.userId});

  @override
  State<MainFeedScreen> createState() => _MainFeedScreenState();
}

class _MainFeedScreenState extends State<MainFeedScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int? _userId;

  List<PostWithCommentCountDto> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchFeed();
  }

  Future<void> _loadUserIdAndFetchFeed() async {
    final userIdStr = await _secureStorage.read(key: 'userId');
    if (userIdStr != null) {
      setState(() => _userId = int.tryParse(userIdStr));
      await fetchFeed();
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
    }
  }

  Future<void> fetchFeed() async {
    setState(() => isLoading = true);

    try {
      final headers = await ApiService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.feed}/friends-feed'),
        headers: headers,
      );

      print('Feed status: ${response.statusCode}');
      print('Feed response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = data
              .map((json) => PostWithCommentCountDto.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget buildPostCard(PostWithCommentCountDto post) {
    final String? imageUrl = post.imageUrl;
    final String backendBaseUrl = getBackendBaseUrl();
    final resolvedUrl = imageUrl != null && imageUrl.isNotEmpty
        ? '$backendBaseUrl$imageUrl'
        : null;

    return InkWell(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommentScreen(postId: post.id),
            ),
          );
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
                  UserAvatar(imageUrl: null, radius: 20),
                  const SizedBox(width: 10),
                  Text(
                    post.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    post.createdAt.toIso8601String().split('T').first,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(post.content),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentScreen(postId: post.id),
                      ),
                    );
                },
                icon: const Icon(Icons.comment, size: 18),
                label: Text('${post.commentCount} comments'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CommonDrawer(currentRoute: '/social-feed'),
      appBar: AppBarHelper.createAppBar(
        context,
        title: 'My Feed',
        centerTitle: true,
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppTheme.primary, // Using centralized theme color
        child: Container(
          height: 56.0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                          Icons.person_search,
                          color: Colors.white
                      ),
                      tooltip: 'Add Friend',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SearchUserScreen(userId: widget.userId)
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      tooltip: 'Friend Requests',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FriendRequestsScreen(userId: widget.userId)
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                          Icons.calendar_today,
                          color: Colors.white
                      ),
                      tooltip: 'Calendar',
                      onPressed: () {
                        // TODO
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      tooltip: 'Messages',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatInboxScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.white,
                        size: 28,
                      ),
                      tooltip: 'Create Post',
                      onPressed: () async {
                        final success = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  NewPostScreen(userId: widget.userId)
                          ),
                        );
                        if (success == true) fetchFeed();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}