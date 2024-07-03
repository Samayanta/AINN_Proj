import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemini/flutter_gemini.dart'; // Import Gemini package
import 'package:ainn_proj/home_screen.dart';
import 'package:ainn_proj/home_screen_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await Gemini.init(apiKey: 'AIzaSyA12p112ZXYzB3OWJPzGmiLVx61S-FFCdg'); // Replace with your actual Gemini API key

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenProvider(),
      child: MaterialApp(
        title: 'Therapist Chat',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            elevation: 0,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
