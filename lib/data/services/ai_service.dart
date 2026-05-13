import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../utils/constants.dart';

class AIService {
  AIService() : _model = _buildModel();

  final GenerativeModel? _model;

  static GenerativeModel? _buildModel() {
    const key = AppConstants.geminiApiKey;
    if (key.isEmpty) return null;
    return GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: key,
    );
  }

  Future<Map<String, String>> analyzeDonationItem(File image) async {
    final model = _model;
    if (model == null) {
      return const {'category': 'Other', 'condition': 'Good'};
    }
    try {
      final imageBytes = await image.readAsBytes();
      final content = [
        Content.multi([
          TextPart(
              "Analyze this donation item. Identify the category (Food, Clothes, or Other) and assess its condition (New, Good, Damaged, or Not Safe). Return only a JSON-like format: {\"category\": \"...\", \"condition\": \"...\", \"reason\": \"...\"}"),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null) throw Exception("Empty response from AI");

      final categoryMatch = RegExp(r'"category":\s*"([^"]+)"').firstMatch(text);
      final conditionMatch = RegExp(r'"condition":\s*"([^"]+)"').firstMatch(text);

      return {
        "category": categoryMatch?.group(1) ?? "Other",
        "condition": conditionMatch?.group(1) ?? "Good",
      };
    } catch (e) {
      // ignore: avoid_print
      print("AI Analysis Error: $e");
      return const {
        "category": "Other",
        "condition": "Good",
      };
    }
  }

  /// Conversational assistant for donation guidance (same Gemini stack as image analysis).
  Future<String> chatDonationAssistant(String userMessage) async {
    final model = _model;
    if (model == null) {
      return 'لم يُضبط مفتاح Gemini. أعد بناء التطبيق مع: flutter build apk --dart-define=GEMINI_API_KEY=مفتاحك\n'
          'Or set GEMINI_API_KEY when building. FAQ answers may still work without a key.';
    }
    try {
      final prompt = StringBuffer()
        ..writeln('You are the in-app assistant for "Don\'t Waste Donate", a charity donation app.')
        ..writeln('Answer briefly and practically. Match the user language (Arabic or English).')
        ..writeln('Topics: how to donate, categories, food safety, photos/AI analysis, account, maps.')
        ..writeln('Do not invent legal or medical guarantees.')
        ..writeln('User: $userMessage');
      final response = await model.generateContent([Content.text(prompt.toString())]);
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return 'تعذر الحصول على رد من الذكاء الاصطناعي. حاول مرة أخرى.';
      }
      return text;
    } catch (e) {
      return 'حدث خطأ أثناء الاتصال بالذكاء الاصطناعي. تحقق من الإنترنت أو المفتاح.\n$e';
    }
  }
}
