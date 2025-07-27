import 'package:dio/dio.dart';

class AiService {
  static const _apiKey = 'sk-b39528d1c130406cb7afc560b6b9fc9a';
static const _baseUrl =
  'https://cors-anywhere.herokuapp.com/https://api.deepseek.com/v1/chat/completions';




  static Future<String> explainLesson(String lessonContent) async {
    final dio = Dio();

    final prompt = """
You are an expert trainer. Explain this lesson more clearly in plain language for a trainee:

$lessonContent
""";

    final payload = {
      "model": "deepseek-chat",
      "messages": [
        {"role": "user", "content": prompt}
      ],
    };
final response = await Dio().post(
  _baseUrl,
  options: Options(headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  }),
  data: {
    "model": "deepseek-chat",
    "messages": [
      {"role": "user", "content": prompt}
    ]
  },
);

    return response.data['choices'][0]['message']['content'];
  }
}
