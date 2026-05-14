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
              "You are a professional donation screening AI for a multi-purpose charity app.\n"
              "Your goal is to maximize helpful donations while ensuring safety.\n\n"
              "Rules:\n"
              "- ACCEPT: Any item that is functional, clean, and useful (e.g., Electronics, Books, Clothes, Food, Tools).\n"
              "- ACCEPT: If the condition is 'New' or 'Good', it MUST be accepted.\n"
              "- REJECT: Only if the item is clearly broken beyond repair, extremely dirty, expired, or dangerous.\n\n"
              "Identify Category: (Food, Clothes, Education, Health, or Shelter).\n"
              "Identify Condition: (New, Good, Damaged).\n"
              "Return ONLY JSON:\n"
              "{\"category\": \"...\", \"condition\": \"...\", \"accepted\": true/false, \"reason\": \"one short sentence explaining why\"}"),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;

      if (text == null) throw Exception("Empty response from AI");

      final categoryMatch = RegExp(r'"category":\s*"([^"]+)"').firstMatch(text);
      final conditionMatch = RegExp(r'"condition":\s*"([^"]+)"').firstMatch(text);
      final acceptedMatch = RegExp(r'"accepted":\s*(true|false)').firstMatch(text);
      final reasonMatch = RegExp(r'"reason":\s*"([^"]+)"').firstMatch(text);

      return {
        "category": categoryMatch?.group(1) ?? "Other",
        "condition": conditionMatch?.group(1) ?? "Good",
        "accepted": acceptedMatch?.group(1) ?? "true",
        "reason": reasonMatch?.group(1) ?? "Item appears suitable for donation.",
      };
    } catch (e) {
      // ignore: avoid_print
      print("AI Analysis Error: $e");
      return const {
        "category": "Other",
        "condition": "Good",
        "accepted": "true",
        "reason": "Could not analyze item. Defaulting to accepted.",
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
