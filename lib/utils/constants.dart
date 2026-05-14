class AppConstants {
  /// Pass at build/run time: `--dart-define=GEMINI_API_KEY=your_key`
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyAvhBeYXNZXZhR0yd2jk4v7PvdpBve_lLo',
  );
  
  /// Pass at build/run time: `--dart-define=GOOGLE_MAPS_API_KEY=your_key`
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyCbmAgJSIKKuIsPSIFZ5bx6uaI2-EPMHlc',
  );
}