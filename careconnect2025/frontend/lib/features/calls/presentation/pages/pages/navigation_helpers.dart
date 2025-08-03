/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // For Uri encoding

void navigateToCallPage({
  required BuildContext context,
  required String userRole,
  required String userId,
  required String roomId,
  required String displayName,
}) {
  final encodedUserId = Uri.encodeComponent(userId);
  final encodedRoomId = Uri.encodeComponent(roomId);
  final encodedDisplayName = Uri.encodeComponent(displayName);

  context.go(
      '/call-page/$userRole/${Uri.encodeComponent(userId)}/${Uri.encodeComponent(roomId)}/${Uri.encodeComponent(displayName)}'
  );

}
*/


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // For Uri encoding
void navigateToCallPage({
  required BuildContext context,
  required String userRole,
  required String userId,
  required String roomId,
  required String displayName,
}) {
  final encodedUserId = Uri.encodeComponent(userId);
  final encodedRoomId = Uri.encodeComponent(roomId);
  final encodedDisplayName = Uri.encodeComponent(displayName);

  final path = '/call-page/$userRole/$encodedUserId/$encodedRoomId/$encodedDisplayName';
  print("Navigating to: $path"); // Optional debug
  context.go(path);
}
