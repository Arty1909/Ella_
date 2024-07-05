// import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();

  late final GenerativeModel model;

  late final ChatDatabase database;

  final List<Message> _messages = [];

  late String _apiKey;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('apiKey') ?? '';
    if (_apiKey.isEmpty) {
      _showApiKeyDialog();
    } else {
      _initializeChat();
    }
  }

  Future<void> _showApiKeyDialog() async {
    String? apiKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your API Key'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'You can obtain your API key from the Gemini website:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'https://aistudio.google.com/app/apikey',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    _apiKey = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter API key',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_apiKey);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (apiKey != null && apiKey.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('apiKey', apiKey);
      setState(() {
        _apiKey = apiKey;
      });
      _initializeChat();
    }
  }

  Future<void> _initializeChat() async {
    model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await _getDatabasePath();
    database = ChatDatabase(dbPath);
    await database.init();
    final messages = await database.getAllMessages();
    setState(() {
      _messages.addAll(messages);
    });
  }

  Future<String> _getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'chat_database.db');
  }

  Future<void> sendMessage() async {
    final message = _userMessage.text.trim();
    if (message.isEmpty) return;
    _userMessage.clear();

    setState(() {
      final newMessage =
          Message(isUser: true, message: message, date: DateTime.now());
      _messages.add(newMessage);
      database.insertMessage(newMessage);
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      final botResponse = Message(
        isUser: false,
        message: response.text ?? "",
        date: DateTime.now(),
      );
      _messages.add(botResponse);
      database.insertMessage(botResponse);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat Bot'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Messages(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 15,
                  child: TextFormField(
                    controller: _userMessage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      label: const Text("Enter your message"),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: const EdgeInsets.all(15),
                  iconSize: 30,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(
                      const CircleBorder(),
                    ),
                  ),
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => deleteChatHistory(),
      //   child: const Icon(Icons.delete),
      // ),
    );
  }

  // Future<void> deleteChatHistory() async {
  //   final dbPath = await _getDatabasePath();
  //   final file = File(dbPath);
  //   await file.delete();
  //   setState(() {
  //     _messages.clear(); // Clear the message list to reflect the change
  //   });
  // }
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;
  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 : 10,
        right: isUser ? 10 : 100,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? const Color.fromARGB(255, 9, 48, 79)
            : Colors.grey.shade300,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(color: isUser ? Colors.white : Colors.black),
          ),
          Text(
            date,
            style: TextStyle(color: isUser ? Colors.white : Colors.black),
          ),
        ],
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  const Message({
    required this.isUser,
    required this.message,
    required this.date,
  });
}

class ChatDatabase {
  late final String _path;
  late Database _database;

  ChatDatabase(String path) {
    _path = path;
  }

  Future<void> init() async {
    _database = await openDatabase(
      _path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, isUser INTEGER, message TEXT, date TEXT)',
        );
      },
    );
  }

  Future<void> insertMessage(Message message) async {
    await _database.insert(
      'messages',
      {
        'isUser': message.isUser ? 1 : 0,
        'message': message.message,
        'date': message.date.toIso8601String(),
      },
    );
  }

  Future<List<Message>> getAllMessages() async {
    final List<Map<String, dynamic>> maps = await _database.query('messages');
    return List.generate(maps.length, (i) {
      return Message(
        isUser: maps[i]['isUser'] == 1,
        message: maps[i]['message'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }
}
