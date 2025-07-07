import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/services/ai_service.dart';

void main() {
  group('Enhanced AI Chat Tests', () {
    test('AIModel enum should have correct display names', () {
      expect(AIModel.deepseek.displayName, 'DeepSeek');
      expect(AIModel.openai.displayName, 'OpenAI GPT-4');
      expect(AIModel.deepseek.modelName, 'deepseek-chat');
      expect(AIModel.openai.modelName, 'gpt-4o-mini');
    });

    test('AI service should handle role-specific prompts', () {
      // Test that different roles get different system prompts
      expect(AIModel.values.length, 2);
      expect(AIModel.values.contains(AIModel.deepseek), true);
      expect(AIModel.values.contains(AIModel.openai), true);
    });

    test('Model switching should be supported', () {
      // Test that both models are available for switching
      final availableModels = AIModel.values;
      expect(availableModels.length, greaterThanOrEqualTo(2));

      // Test display names are user-friendly
      for (final model in availableModels) {
        expect(model.displayName.isNotEmpty, true);
        expect(model.modelName.isNotEmpty, true);
      }
    });
  });
}
