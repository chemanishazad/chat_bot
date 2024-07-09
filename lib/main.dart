import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';

import 'package:chatbot/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// Secure your API key properly
final chatGpt = ChatGpt(apiKey: '');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
        ),
        home: HomePage());
  }
}
