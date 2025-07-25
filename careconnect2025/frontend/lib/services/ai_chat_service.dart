import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../config/env_constant.dart';

/// Service for AI chat communication through Spring Boot backend
class AIChatService {
  static String get _baseUrl => '${getBackendBaseUrl()}/v1/api/ai-chat';

  /// Send a chat message to the AI through the backend
  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required int patientId,
    required int userId,
    String? conversationId,
    String chatType = 'GENERAL_SUPPORT',
    String? title,
    String preferredModel = 'deepseek-chat',
    double temperature = 0.7,
    int maxTokens = 1000,
    bool includeVitals = false,
    bool includeMedications = false,
    bool includeNotes = false,
    bool includeMoodPainLogs = false,
    bool includeAllergies = false,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      authHeaders['Content-Type'] = 'application/json';
      authHeaders['Accept'] = '*/*';

      final requestBody = {
        'message': message,
        'patientId': patientId,
        'userId': userId,
        if (conversationId != null) 'conversationId': conversationId,
        'chatType': chatType,
        if (title != null) 'title': title,
        'preferredModel': preferredModel,
        'temperature': temperature,
        'maxTokens': maxTokens,
        'includeVitals': includeVitals,
        'includeMedications': includeMedications,
        'includeNotes': includeNotes,
        'includeMoodPainLogs': includeMoodPainLogs,
        'includeAllergies': includeAllergies,
      };

      print('🤖 Sending AI chat message: ${requestBody['message']}');

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      print('🤖 AI chat response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending AI chat message: $e');
      return {
        'success': false,
        'error': 'Failed to send message: $e',
        'response': 'Sorry, I encountered an error. Please try again later.',
      };
    }
  }

  /// Get conversation history
  static Future<List<Map<String, dynamic>>> getConversationHistory({
    required String userId,
    String? conversationId,
    int limit = 50,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      final params = {
        'userId': userId,
        if (conversationId != null) 'conversationId': conversationId,
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '$_baseUrl/history',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: authHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        throw Exception(
          'Failed to get conversation history: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error getting conversation history: $e');
      return [];
    }
  }

  /// Start a new conversation
  static Future<String?> startNewConversation({
    required String userId,
    String? title,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      final requestBody = {'userId': userId, if (title != null) 'title': title};

      final response = await http.post(
        Uri.parse('$_baseUrl/conversation/new'),
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['conversationId'];
      } else {
        throw Exception(
          'Failed to start new conversation: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error starting new conversation: $e');
      return null;
    }
  }

  /// Get user conversations list
  static Future<List<Map<String, dynamic>>> getUserConversations({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      final params = {'userId': userId, 'limit': limit.toString()};

      final uri = Uri.parse(
        '$_baseUrl/conversations',
      ).replace(queryParameters: params);

      final response = await http.get(uri, headers: authHeaders);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['conversations'] ?? []);
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting conversations: $e');
      return [];
    }
  }

  /// Delete a conversation
  static Future<bool> deleteConversation({
    required String conversationId,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      final response = await http.delete(
        Uri.parse('$_baseUrl/conversation/$conversationId'),
        headers: authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      return false;
    }
  }

  /// Send file for AI analysis
  static Future<String> analyzeFile({
    required String filePath,
    required String userId,
    String? question,
    String? conversationId,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/analyze-file'),
      );

      // Add headers
      request.headers.addAll(authHeaders);

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Add form fields
      request.fields['userId'] = userId;
      if (question != null) request.fields['question'] = question;
      if (conversationId != null) {
        request.fields['conversationId'] = conversationId;
      }

      print('🤖 Uploading file for AI analysis: $filePath');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🤖 File analysis response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'File analyzed successfully';
      } else {
        throw Exception('Failed to analyze file: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error analyzing file: $e');
      return 'Sorry, I encountered an error analyzing the file. Please try again later.';
    }
  }

  /// Get AI configuration for a patient
  static Future<Map<String, dynamic>?> getAIConfiguration({
    required int patientId,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      print('🤖 Getting AI config for patient $patientId');

      final response = await http.get(
        Uri.parse('$_baseUrl/config/$patientId'),
        headers: authHeaders,
      );

      print('🤖 AI config response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('🤖 No AI config found for patient $patientId');
        return null;
      } else {
        throw Exception(
          'Failed to get AI configuration: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error getting AI configuration: $e');
      return null;
    }
  }

  /// Update AI configuration for user
  static Future<bool> updateAIConfiguration({
    required int patientId,
    required Map<String, dynamic> configuration,
  }) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      authHeaders['Content-Type'] = 'application/json';
      authHeaders['Accept'] = '*/*';

      final requestBody = {
        'patientId': patientId,
        'aiProvider': configuration['aiProvider'] ?? 'DEEPSEEK',
        'openaiModel': configuration['openaiModel'] ?? 'gpt-3.5-turbo',
        'deepseekModel': configuration['deepseekModel'] ?? 'deepseek-chat',
        'maxTokens': configuration['maxTokens'] ?? 1000,
        'temperature': configuration['temperature'] ?? 0.7,
        'conversationHistoryLimit':
            configuration['conversationHistoryLimit'] ?? 20,
        'includeVitalsByDefault':
            configuration['includeVitalsByDefault'] ?? true,
        'includeMedicationsByDefault':
            configuration['includeMedicationsByDefault'] ?? true,
        'includeNotesByDefault': configuration['includeNotesByDefault'] ?? true,
        'includeMoodPainLogsByDefault':
            configuration['includeMoodPainLogsByDefault'] ?? true,
        'includeAllergiesByDefault':
            configuration['includeAllergiesByDefault'] ?? true,
        'isActive': configuration['isActive'] ?? true,
        'systemPrompt':
            configuration['systemPrompt'] ??
            "You are a helpful health assistant for patients. Only answer questions related to health, wellness, psychosocial support, or medical topics. If the question is not related to health, respond with 'I can only assist with health-related questions.'",
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/config'),
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Error updating AI configuration: $e');
      return false;
    }
  }
}
