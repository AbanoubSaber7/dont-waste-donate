class AppConstants {
  /// Pass at build/run time: `--dart-define=GEMINI_API_KEY=your_key`
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}