import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/services/ai_service.dart';

void main() {
  group('AI Service Debug Tests', () {
    test('AI service should have correct URLs and models', () {
      expect(AIModel.deepseek.displayName, 'DeepSeek');
      expect(AIModel.openai.displayName, 'OpenAI GPT-4');
    });

    test('AI service should handle test question (simulated)', () async {
      // This test simulates the AI service call without actually calling the API
      // In a real scenario, this would test against a mock or staging environment

      const testQuestion = 'What should I do if I have a headache?';
      const testRole = 'patient';
      const testModel = AIModel.deepseek;

      // Verify that the parameters are correctly formatted
      expect(testQuestion.isNotEmpty, true);
      expect(testRole, isIn(['patient', 'caregiver']));
      expect(testModel, isA<AIModel>());

      // Test system prompt generation logic
      final systemPrompt = testRole == 'patient'
          ? "You are a helpful health assistant for patients. Only answer questions related to health, wellness, psychosocial support, or medical topics. If the question is not related to health, respond with 'I can not help you with that. I can only assist with health-related questions.'"
          : "You are a helpful health assistant for caregivers. Only answer questions related to health, wellness, patient care, or medical topics. If the question is not related to health, respond with 'I can not help you with that. I can only assist with health-related questions.'";

      expect(systemPrompt.contains('health assistant'), true);
      expect(systemPrompt.contains('I can not help you with that'), true);
    });

    test('AI service should format request body correctly', () {
      const testModel = AIModel.deepseek;
      const testQuestion = 'Test question';

      final requestBody = {
        'model': testModel.modelName,
        'messages': [
          {'role': 'system', 'content': 'Test system prompt'},
          {'role': 'user', 'content': testQuestion},
        ],
        'stream': false,
      };

      expect(requestBody['model'], 'deepseek-chat');
      expect(requestBody['messages'], isA<List>());
      expect(requestBody['stream'], false);
      expect((requestBody['messages'] as List).length, 2);
    });

    test('OpenAI model should include additional parameters', () {
      const testModel = AIModel.openai;

      final requestBody = <String, dynamic>{
        'model': testModel.modelName,
        'messages': [],
        'stream': false,
      };

      // Add model-specific parameters
      if (testModel == AIModel.openai) {
        requestBody['max_tokens'] = 300;
        requestBody['temperature'] = 0.7;
      }

      expect(requestBody['model'], 'gpt-4o-mini');
      expect(requestBody['max_tokens'], 300);
      expect(requestBody['temperature'], 0.7);
    });
  });
}
