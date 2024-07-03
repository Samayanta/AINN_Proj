
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  static late final Gemini _gemini;

  static Future<void> initialize() async {
    _gemini = Gemini.instance;
  
  }

  static Gemini get instance {
    if (_gemini == null) {
      throw Exception("Gemini has not been initialized.");
    }
    return _gemini;
  }
}
