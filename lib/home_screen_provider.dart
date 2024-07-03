import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _isListening = false;
  bool get isListening => _isListening;

  String _response = '';
  String get response => _response;

  TextEditingController _controller = TextEditingController();
  TextEditingController get controller => _controller;

  final gemini = Gemini.instance;

  void toggleListening() {
    _isListening = !_isListening;
    notifyListeners();
  }

  void sendMessage(String message) async {
    _response = message; // Update response immediately
    notifyListeners();

    try {
      final response = await gemini.streamGenerateContent(message);

      response.listen((data) {
        // Handle Gemini responses here
        _response = _extractTextFromResponse(data); // Extract text from Gemini output
        notifyListeners();
      });
    } catch (e) {
      _response = 'Error: $e';
      notifyListeners();
    }
  }

  String _extractTextFromResponse(Candidates? candidates) {
    if (candidates?.content?.parts?.isNotEmpty ?? false) {
      return candidates!.content!.parts![0].text ?? 'No response'; // Use null-aware operators to safely access properties
    }
    return 'No response';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
