import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini API Example'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => HomeScreenProvider(),
        child: Consumer<HomeScreenProvider>(
          builder: (context, provider, _) => Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    provider.response.isEmpty
                        ? 'Tap the mic and speak'
                        : provider.response,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              _buildInputArea(context, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, HomeScreenProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(provider.isListening ? Icons.mic : Icons.mic_none,
                color: Colors.deepPurple),
            onPressed: () {
              provider.toggleListening();
              // Add speech to text functionality if needed
            },
          ),
          Expanded(
            child: TextField(
              controller: provider.controller,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => provider.sendMessage(provider.controller.text),
                ),
              ),
              onSubmitted: (message) => provider.sendMessage(message),
            ),
          ),
        ],
      ),
    );
  }
}
