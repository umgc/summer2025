import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:care_connect_app/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:care_connect_app/shared/widgets/user_avatar.dart';
import 'package:care_connect_app/services/session_manager.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'search_user_screen.dart';
import 'comment_screen.dart';
import 'friend_requests_screen.dart';
import 'new_post_screen.dart';
import 'package:care_connect_app/config/env_constant.dart';

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
    final session = SessionManager();
    await session.restoreSession();

    try {
      print('Headers before request: ${session.headers}');
      final http.Response response = await session.get(
        '${ApiConstants.feed}/all',
      );

      print('Feed status: ${response.statusCode}');
      print('Feed response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          posts = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to load feed')));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget buildPostCard(Map<String, dynamic> post) {
    final imageUrl = post['imageUrl'];
    final String backendBaseUrl =
        getBackendBaseUrl(); // Change for emulator if needed!
    final resolvedUrl = imageUrl != null && imageUrl.isNotEmpty
        ? '$backendBaseUrl$imageUrl'
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    post['timestamp'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      drawer: const CommonDrawer(currentRoute: '/social-feed'),
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
                        color: Colors.white,
                      ),
                      tooltip: 'Add Friend',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SearchUserScreen(userId: widget.userId),
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
                                FriendRequestsScreen(userId: widget.userId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
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
                        // TODO
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
                                NewPostScreen(userId: widget.userId),
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
