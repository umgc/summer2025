import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_constant.dart';

enum AIModel {
  deepseek('DeepSeek', 'deepseek-chat'),
  openai('OpenAI GPT-4', 'gpt-4o-mini');

  const AIModel(this.displayName, this.modelName);
  final String displayName;
  final String modelName;
}

class AIService {
  static const String _deepseekUrl =
      'https://api.deepseek.com/chat/completions';
  static const String _openaiUrl = 'https://api.openai.com/v1/chat/completions';

  // Performance optimization: Cache for recent responses
  static final Map<String, String> _responseCache = {};
  static const int _maxCacheSize = 100;
  static const Duration _cacheTimeout = Duration(minutes: 10);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Connection pooling for better performance
  static final http.Client _httpClient = http.Client();

  static Future<String> askAI(
    String question, {
    String role = 'patient',
    AIModel model = AIModel.deepseek,
    String? healthDataContext,
  }) async {
    // Create cache key
    final cacheKey = _createCacheKey(question, role, model, healthDataContext);

    // Check cache first
    if (_responseCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null &&
          DateTime.now().difference(timestamp) < _cacheTimeout) {
        return _responseCache[cacheKey]!;
      } else {
        // Remove expired cache entry
        _responseCache.remove(cacheKey);
        _cacheTimestamps.remove(cacheKey);
      }
    }

    try {
      final baseUrl = model == AIModel.deepseek ? _deepseekUrl : _openaiUrl;
      String apiKey;

      // Get API key based on model from environment variables
      if (model == AIModel.deepseek) {
        // For DeepSeek, get the key from environment variables
        try {
          apiKey = getDeepSeekKey();
          // Remove "Bearer " prefix if present
          if (apiKey.startsWith('Bearer ')) {
            apiKey = apiKey.substring(7);
          }
        } catch (e) {
          // Debug: Error getting DeepSeek API key: $e
          throw Exception(
            'DeepSeek API key not configured. Please set DEEPSEEK_API_KEY in environment variables.',
          );
        }
      } else {
        // For OpenAI, get the key from environment variables
        try {
          apiKey = getOpenAIKey();
        } catch (e) {
          // Debug: Error getting OpenAI API key: $e
          throw Exception(
            'OpenAI API key not configured. Please set OPENAI_API_KEY in environment variables.',
          );
        }
      }

      // Health-related system prompt with role-specific context
      String systemPrompt;
      if (role == 'analytics') {
        systemPrompt =
            "You are a specialized health data analyst AI assistant. You have the ability to analyze patient health data from uploaded files, text content, and documents. When users upload files, you have direct access to read and analyze the content. You provide insights, interpretations, and recommendations based on the data provided. You help healthcare professionals and caregivers understand health trends, identify potential concerns, and make data-driven decisions. IMPORTANT: Personal identifiers have been removed from all data for privacy protection. Only answer questions related to health data analysis, medical insights, or patient care recommendations. If asked about non-health topics, respond with 'I can only assist with health data analysis and medical insights.'";
      } else if (role == 'patient') {
        systemPrompt =
            "You are a helpful health assistant for patients. You have the ability to read and analyze any files or documents that users upload to help answer their health-related questions. When users upload files (like medical reports, lab results, health documents, CSV data, or text files), you can access and analyze the content directly to provide relevant health advice. You can process various file formats including text files, CSV files, JSON data, and more. Only answer questions related to health, wellness, psychosocial support, or medical topics. If the question is not related to health, respond with 'I can not help you with that. I can only assist with health-related questions.'";
      } else {
        systemPrompt =
            "You are a helpful health assistant for caregivers. You have the ability to read and analyze any files or documents that users upload to help with patient care. When users upload files (like medical reports, patient records, health documents, CSV data, or text files), you can access and analyze the content directly to provide relevant caregiving advice. You can process various file formats including text files, CSV files, JSON data, and more. Only answer questions related to health, wellness, patient care, or medical topics. If the question is not related to health, respond with 'I can not help you with that. I can only assist with health-related questions.'";
      }

      final messages = [
        {'role': 'system', 'content': systemPrompt},
      ];

      // Add health data context (including file content) if provided
      if (healthDataContext != null && healthDataContext.isNotEmpty) {
        // Check if this contains file data
        if (healthDataContext.contains(
              'The user has uploaded the following files',
            ) ||
            healthDataContext.contains('=== UPLOADED FILES CONTEXT ===')) {
          messages.add({
            'role': 'system',
            'content':
                'I have access to the following uploaded file content. I can read and analyze this data directly:\n\n$healthDataContext',
          });
        } else {
          // Regular health data context
          messages.add({
            'role': 'system',
            'content':
                'Here is the current patient health data for your analysis:\n\n$healthDataContext',
          });
        }
      }

      messages.add({'role': 'user', 'content': question});

      final requestBody = {
        'model': model.modelName,
        'messages': messages,
        'stream': false,
      };

      // Add model-specific parameters
      if (model == AIModel.openai) {
        requestBody['max_tokens'] = 1000; // Increased for file analysis
        requestBody['temperature'] = 0.7;
      } else {
        // DeepSeek parameters for better file analysis
        requestBody['max_tokens'] = 1000;
        requestBody['temperature'] = 0.7;
      }

      final response = await _httpClient
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 120),
          ); // Reduced timeout for better UX

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Cache the response
        _cacheResponse(cacheKey, content);

        return content;
      } else {
        return 'Sorry, I encountered an error. Please try again later. (${response.statusCode})';
      }
    } catch (e) {
      // Better error handling
      if (e.toString().contains('TimeoutException')) {
        return 'The request timed out. Please try again with a shorter message.';
      } else if (e.toString().contains('SocketException')) {
        return 'Network error. Please check your internet connection and try again.';
      } else {
        return 'Sorry, I encountered an error. Please try again later. ($e)';
      }
    }
  }

  // Helper method to create cache key
  static String _createCacheKey(
    String question,
    String role,
    AIModel model,
    String? healthDataContext,
  ) {
    final contextHash = healthDataContext?.hashCode ?? 0;
    return '${question.hashCode}_${role}_${model.modelName}_$contextHash';
  }

  // Helper method to cache responses
  static void _cacheResponse(String key, String response) {
    // Implement LRU cache by removing oldest entries when cache is full
    if (_responseCache.length >= _maxCacheSize) {
      final oldestKey = _cacheTimestamps.keys.first;
      _responseCache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }

    _responseCache[key] = response;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Method to clear cache (useful for testing or memory management)
  static void clearCache() {
    _responseCache.clear();
    _cacheTimestamps.clear();
  }

  // Method to dispose of resources
  static void dispose() {
    _httpClient.close();
    clearCache();
  }

  // Legacy method for backward compatibility
  static Future<String> askHealthQuestion(String question) async {
    return askAI(question, role: 'patient', model: AIModel.deepseek);
  }
}
