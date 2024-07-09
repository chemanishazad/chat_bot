import 'package:chat_gpt_flutter/chat_gpt_flutter.dart';
import 'package:chatbot/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController promptController;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    promptController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Chat Bot',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return ChatBubble(
                  text: message['text']!,
                  isUser: message['role'] == 'user',
                  timestamp: message['timestamp']!,
                );
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: promptController,
                decoration: InputDecoration(
                  hintText: 'Enter your prompt',
                  hintStyle: const TextStyle(color: Colors.black54),
                  contentPadding: const EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onFieldSubmitted: (_) => _completionFun(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: isLoading ? null : _completionFun,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _completionFun() async {
    if (promptController.text.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();
    setState(() {
      messages.add({
        'role': 'user',
        'text': promptController.text,
        'timestamp': timestamp,
      });
      isLoading = true;
    });

    final userMessage = promptController.text;
    promptController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${chatGpt.apiKey}'
        },
        body: jsonEncode(
          {
            'model': "gpt-3.5-turbo",
            'messages': [
              {
                'role': 'user',
                'content': userMessage,
              }
            ],
            "max_tokens": 250,
            "temperature": 1,
            "top_p": 1,
            'frequency_penalty': 0,
            "presence_penalty": 0,
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          messages.add({
            'role': 'bot',
            'text': responseBody['choices'][0]['message']['content'],
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      } else {
        final errorResponse = jsonDecode(response.body);
        setState(() {
          messages.add({
            'role': 'bot',
            'text': 'Error: ${errorResponse['error']['message']}',
            'timestamp': DateTime.now().toIso8601String(),
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'bot',
          'text': 'Error: $e',
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
    } finally {
      setState(() {
        isLoading = false;
      });
      _scrollToBottom();
    }
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  final String text;
  final bool isUser;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser)
                const CircleAvatar(
                    child: Icon(Icons.android, color: Colors.white),
                    backgroundColor: Colors.grey),
              if (isUser) const SizedBox(width: 40),
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUser
                        ? [Colors.blueAccent, Colors.lightBlueAccent]
                        : [Colors.grey, Colors.blueGrey],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isUser ? 12 : 0),
                    topRight: Radius.circular(isUser ? 0 : 12),
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (isUser)
                const CircleAvatar(
                    child: Icon(Icons.person, color: Colors.white),
                    backgroundColor: Colors.blue),
              if (!isUser) const SizedBox(width: 40),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
            child: Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final time = TimeOfDay.fromDateTime(dateTime);
    final formattedTime =
        '${time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} $formattedTime';
  }
}
