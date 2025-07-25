import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../config/env_constant.dart';

/// DTO classes for AI configuration
class PatientAIConfigDTO {
  final int? id;
  final int patientId;
  final String aiModel;
  final double temperature;
  final int maxTokens;
  final bool medicalContextEnabled;
  final bool personalityAdaptation;
  final String preferredTone;
  final List<String> specialInstructions;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PatientAIConfigDTO({
    this.id,
    required this.patientId,
    required this.aiModel,
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.medicalContextEnabled = true,
    this.personalityAdaptation = false,
    this.preferredTone = 'friendly',
    this.specialInstructions = const [],
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  factory PatientAIConfigDTO.fromJson(Map<String, dynamic> json) {
    return PatientAIConfigDTO(
      id: json['id'],
      patientId: json['patientId'],
      aiModel: json['aiModel'],
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] ?? 1000,
      medicalContextEnabled: json['medicalContextEnabled'] ?? true,
      personalityAdaptation: json['personalityAdaptation'] ?? false,
      preferredTone: json['preferredTone'] ?? 'friendly',
      specialInstructions: List<String>.from(json['specialInstructions'] ?? []),
      active: json['active'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'patientId': patientId,
      'aiModel': aiModel,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'medicalContextEnabled': medicalContextEnabled,
      'personalityAdaptation': personalityAdaptation,
      'preferredTone': preferredTone,
      'specialInstructions': specialInstructions,
      'active': active,
    };
  }
}

class ChatRequest {
  final String message;
  final int patientId;
  final int userId;
  final String? conversationId;
  final String? medicalContext;
  final String role;

  ChatRequest({
    required this.message,
    required this.patientId,
    required this.userId,
    this.conversationId,
    this.medicalContext,
    this.role = 'patient',
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'patientId': patientId,
      'userId': userId,
      if (conversationId != null) 'conversationId': conversationId,
      if (medicalContext != null) 'medicalContext': medicalContext,
      'role': role,
    };
  }
}

class ChatResponse {
  final bool success;
  final String? response;
  final String? conversationId;
  final String? errorMessage;
  final String? errorCode;
  final DateTime? timestamp;

  ChatResponse({
    required this.success,
    this.response,
    this.conversationId,
    this.errorMessage,
    this.errorCode,
    this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'] ?? false,
      response: json['response'],
      conversationId: json['conversationId'],
      errorMessage: json['errorMessage'],
      errorCode: json['errorCode'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}

class ChatConversationSummary {
  final String id;
  final String title;
  final DateTime lastMessageAt;
  final int messageCount;
  final bool active;

  ChatConversationSummary({
    required this.id,
    required this.title,
    required this.lastMessageAt,
    required this.messageCount,
    this.active = true,
  });

  factory ChatConversationSummary.fromJson(Map<String, dynamic> json) {
    return ChatConversationSummary(
      id: json['id'],
      title: json['title'],
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      messageCount: json['messageCount'],
      active: json['active'] ?? true,
    );
  }
}

class ChatMessageSummary {
  final String id;
  final String message;
  final String sender;
  final DateTime timestamp;
  final bool isAiResponse;

  ChatMessageSummary({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    required this.isAiResponse,
  });

  factory ChatMessageSummary.fromJson(Map<String, dynamic> json) {
    return ChatMessageSummary(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
      isAiResponse: json['isAiResponse'] ?? false,
    );
  }
}

/// Service for managing AI chat configurations and conversations
class AIChatConfigService {
  static String get _baseUrl => '${getBackendBaseUrl()}/v1/api/ai-chat';
  static final http.Client _httpClient = http.Client();

  /// Get patient AI configuration
  static Future<PatientAIConfigDTO?> getPatientAIConfig(int patientId) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();

      print('🤖 Getting AI config for patient $patientId');

      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/config/$patientId'),
        headers: authHeaders,
      );

      print('🤖 AI config response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PatientAIConfigDTO.fromJson(data);
      } else if (response.statusCode == 404) {
        // No configuration found - return null
        print('🤖 No AI config found for patient $patientId');
        return null;
      } else {
        throw Exception('Failed to get AI config: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting patient AI config: $e');
      return null;
    }
  }

  /// Save or update patient AI configuration
  static Future<PatientAIConfigDTO?> savePatientAIConfig(
    PatientAIConfigDTO config,
  ) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      authHeaders['Content-Type'] = 'application/json';
      authHeaders['Accept'] = '*/*';

      // Convert to the correct API format
      final requestBody = {
        'patientId': config.patientId,
        'aiProvider': config.aiModel.toUpperCase(),
        'openaiModel': 'gpt-3.5-turbo',
        'deepseekModel': config.aiModel,
        'maxTokens': config.maxTokens,
        'temperature': config.temperature,
        'conversationHistoryLimit': 20,
        'includeVitalsByDefault': config.medicalContextEnabled,
        'includeMedicationsByDefault': config.medicalContextEnabled,
        'includeNotesByDefault': config.medicalContextEnabled,
        'includeMoodPainLogsByDefault': config.medicalContextEnabled,
        'includeAllergiesByDefault': config.medicalContextEnabled,
        'isActive': config.active,
        'systemPrompt': config.specialInstructions.isNotEmpty
            ? config.specialInstructions.join(' ')
            : "You are a helpful health assistant for patients. Only answer questions related to health, wellness, psychosocial support, or medical topics. If the question is not related to health, respond with 'I can only assist with health-related questions.'",
      };

      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/config'),
        headers: authHeaders,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PatientAIConfigDTO.fromJson(data);
      } else {
        throw Exception('Failed to save AI config: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving patient AI config: $e');
      return null;
    }
  }

  /// Deactivate patient AI configuration
  static Future<bool> deactivatePatientAIConfig(int patientId) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/config/$patientId'),
        headers: authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deactivating patient AI config: $e');
      return false;
    }
  }

  /// Send chat message using backend AI service
  static Future<ChatResponse?> sendChatMessage(ChatRequest request) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {...authHeaders, 'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to send chat message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending chat message: $e');
      return ChatResponse(
        success: false,
        errorMessage: 'Failed to send message: $e',
        errorCode: 'NETWORK_ERROR',
      );
    }
  }

  /// Get patient's chat conversations
  static Future<List<ChatConversationSummary>> getPatientConversations(
    int patientId,
  ) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/conversations/$patientId'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => ChatConversationSummary.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to get conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting patient conversations: $e');
      return [];
    }
  }

  /// Get messages from a specific conversation
  static Future<List<ChatMessageSummary>> getConversationMessages(
    String conversationId,
  ) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/conversation/$conversationId/messages'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessageSummary.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to get conversation messages: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error getting conversation messages: $e');
      return [];
    }
  }

  /// Deactivate a conversation
  static Future<bool> deactivateConversation(String conversationId) async {
    try {
      final authHeaders = await ApiService.getAuthHeaders();
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/conversation/$conversationId/deactivate'),
        headers: authHeaders,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deactivating conversation: $e');
      return false;
    }
  }

  /// Dispose of resources
  static void dispose() {
    _httpClient.close();
  }
}
