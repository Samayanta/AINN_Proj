import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  String _selectedModel = 'gemma:2b';
  final List<String> _models = [
    'stable-code:3b-code-q4_0',
    'phi3:mini',
    'gemma:2b',
    'llama3:latest'
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == stt.SpeechToText.listeningStatus;
        });
      },
    );
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Chat App', style: TextStyle(color: Colors.white)),
        actions: [
          DropdownButton<String>(
            value: _selectedModel,
            icon: Icon(Icons.arrow_downward, color: Colors.white),
            dropdownColor: Colors.deepPurple,
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.white),
            underline: Container(
              height: 2,
              color: Colors.white,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedModel = newValue!;
              });
              print("Model changed to: $_selectedModel");
            },
            items: _models.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageTile(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Map<String, String> message) {
    final isUserMessage = message.containsKey('user');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUserMessage
                  ? Colors.deepPurple.shade100
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              isUserMessage ? message['user']! : message['bot']!,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                color: Colors.deepPurple),
            onPressed: _listen,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                suffixIcon:
                    _isListening ? Icon(Icons.mic, color: Colors.red) : null,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.deepPurple),
            onPressed: () => _sendMessage(_controller.text),
          ),
          IconButton(
            icon: Icon(Icons.upload_file, color: Colors.deepPurple),
            onPressed: _pickFile,
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) async {
    if (message.isEmpty) return;
    setState(() {
      _messages.add({'user': message});
      _messages.add({'bot': ''});
    });
    _controller.clear();

    print("Sending message: $message");
    print("Selected model: $_selectedModel");

    try {
      final response = await http.get(
        Uri.parse(
            'http://0.0.0.0:8080/query?question=${Uri.encodeComponent(message)}&model=$_selectedModel'),
      );

      print("HTTP response status: ${response.statusCode}");
      print("HTTP response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('response')) {
          String fullResponse = data['response'];
          _animateHackerEffect(fullResponse);
          // Delay TTS until animation is complete
          Future.delayed(
              Duration(milliseconds: 30 * (fullResponse.length / 5).ceil()),
              () {
            _flutterTts.speak(fullResponse);
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load response');
      }
    } catch (e) {
      setState(() {
        _messages.last['bot'] = 'Error: ${e.toString()}';
      });
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result != null) {
        PlatformFile file = result.files.first;
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://0.0.0.0:8080/upload'),
        );
        request.files
            .add(await http.MultipartFile.fromPath('file', file.path!));
        var response = await request.send();
        if (response.statusCode == 200) {
          _showSuccessSnackBar('File uploaded successfully');
        } else {
          throw Exception('File upload failed');
        }
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _listen() async {
    print('Listen method called');
    if (!_isListening) {
      print('Initializing speech recognition');
      bool available = await _speech.initialize(
        onStatus: (status) {
          print('Speech recognition status: $status');
          setState(() {
            _isListening = status == 'listening';
          });
        },
        onError: (error) => print('Speech recognition error: $error'),
      );
      if (available) {
        print('Speech recognition available');
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            print('Speech recognition result: ${result.recognizedWords}');
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 5),
          partialResults: false,
          onSoundLevelChange: (level) => print('Sound level: $level'),
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        print('Speech recognition not available');
      }
    } else {
      print('Stopping speech recognition');
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _animateHackerEffect(String text) {
    List<bool> revealed = List.filled(text.length, false);
    String currentText = List.filled(text.length, '_').join();
    int revealedCount = 0;

    void revealNextChars() {
      if (revealedCount < text.length) {
        int charsToReveal = min(5, text.length - revealedCount);
        for (int i = 0; i < charsToReveal; i++) {
          int index;
          do {
            index = Random().nextInt(text.length);
          } while (revealed[index]);

          revealed[index] = true;
          currentText = currentText.replaceRange(index, index + 1, text[index]);
          revealedCount++;
        }

        setState(() {
          _messages.last['bot'] = currentText;
        });

        Future.delayed(Duration(milliseconds: 30), revealNextChars);
      }
    }

    revealNextChars();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
