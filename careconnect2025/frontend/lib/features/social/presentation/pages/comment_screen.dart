import 'dart:convert';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/common_drawer.dart';

import 'package:care_connect_app/config/env_constant.dart';
import 'package:care_connect_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../model/comment_dto.dart';
class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({super.key, required this.postId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<CommentDto> comments = [];

  final TextEditingController _commentController = TextEditingController();
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() => isLoading = true);

    final url = '${getBackendBaseUrl()}/v1/api/comments/post/${widget.postId}';

    try {
      final headers = await ApiService.getAuthHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);

      print('Comments GET status: ${response.statusCode}');
      print('Comments GET body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          comments = (data as List)
              .map((json) => CommentDto.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> submitComment() async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'userId');
    final username = await storage.read(key: 'name');
    print('DEBUG — Loaded username from secure storage: $username');

    if (userId == null || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID missing or comment empty')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final url = '${getBackendBaseUrl()}/v1/api/comments/post/${widget.postId}';
    final headers = await ApiService.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final body = jsonEncode({
      'userId': int.parse(userId),
      'username': username,
      'content': _commentController.text.trim(),
    });

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    setState(() => isSubmitting = false);

    print('Submit comment status: ${response.statusCode}');
    print('Submit comment body: ${response.body}');

    if (response.statusCode == 201) {
      _commentController.clear();
      fetchComments();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
    }
  }

  Widget buildCommentCard(CommentDto comment) {
    return ListTile(
      leading: const Icon(Icons.comment),
      title: Text(comment.username ?? 'Unknown User'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment.content),
          const SizedBox(height: 4),
          Text(
            comment.timestamp.toIso8601String().split('T').join(' at '),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHelper.createAppBar(context, title: 'Comments'),
      drawer: const CommonDrawer(currentRoute: '/comments'),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                ? const Center(child: Text('No comments yet.'))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return buildCommentCard(comments[index]);
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitComment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
