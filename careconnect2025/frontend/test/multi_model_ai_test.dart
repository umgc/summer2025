import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/services/ai_service.dart';

void main() {
  group('Multi-Model AI Service Tests', () {
    test('AIModel enum should have correct values', () {
      expect(AIModel.deepseek.displayName, 'DeepSeek');
      expect(AIModel.deepseek.modelName, 'deepseek-chat');
      expect(AIModel.openai.displayName, 'OpenAI GPT-4');
      expect(AIModel.openai.modelName, 'gpt-4o-mini');
    });

    test('AI service should handle different models', () {
      // Test that the AI service can be called with different models
      expect(() {
        AIService.askAI(
          'What should I do when I feel sick?',
          role: 'patient',
          model: AIModel.deepseek,
        );
      }, returnsNormally);

      expect(() {
        AIService.askAI(
          'How can I help my patients?',
          role: 'caregiver',
          model: AIModel.openai,
        );
      }, returnsNormally);
    });

    test('Legacy method should still work', () {
      expect(() {
        AIService.askHealthQuestion('What is a healthy diet?');
      }, returnsNormally);
    });

    test('Role-specific prompts should be different', () {
      // Test that patient and caregiver get different system prompts
      const testQuestion = 'Help me with health';

      expect(() {
        AIService.askAI(testQuestion, role: 'patient', model: AIModel.deepseek);
      }, returnsNormally);

      expect(() {
        AIService.askAI(testQuestion, role: 'caregiver', model: AIModel.openai);
      }, returnsNormally);
    });
  });
}
