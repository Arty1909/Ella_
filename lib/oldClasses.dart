// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:intl/intl.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Gemini AI ChatBot',
//       home: InstructionScreen(),
//     );
//   }
// }





// class InstructionScreen extends StatefulWidget {
//   @override
//   _InstructionScreenState createState() => _InstructionScreenState();
// }

// class _InstructionScreenState extends State<InstructionScreen> {
//   final TextEditingController _apiKeyController = TextEditingController();
//   late final SharedPreferences _prefs;
//   String? _savedApiKey;

//   @override
//   void initState() {
//     super.initState();
//     _initializeSharedPreferences();
//   }

//   Future<void> _initializeSharedPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//     _savedApiKey = _prefs.getString('apiKey');
//     if (_savedApiKey != null && _savedApiKey!.isNotEmpty) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ChatScreen(apiKey: _savedApiKey!),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Instruction'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Instructions:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               '1. Go to Gemini website and create an account.',
//             ),
//             Text(
//               '2. Generate your API Key in the settings.',
//             ),
//             Text(
//               '3. Copy your API Key and paste it below:',
//             ),
//             TextField(
//               controller: _apiKeyController,
//               decoration: InputDecoration(labelText: 'Enter your API Key'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 final apiKey = _apiKeyController.text.trim();
//                 if (apiKey.isNotEmpty) {
//                   await _prefs.setString('apiKey', apiKey);
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ChatScreen(apiKey: apiKey),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Please enter your API Key.'),
//                     ),
//                   );
//                 }
//               },
//               child: Text('Save API Key'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }





// class ChatScreen extends StatefulWidget {
//   final String apiKey;

//   const ChatScreen({Key? key, required this.apiKey}) : super(key: key);

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _userMessage = TextEditingController();

//   late final GenerativeModel model;

//   late final ChatDatabase database;

//   final List<Message> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     model = GenerativeModel(model: 'gemini-pro', apiKey: widget.apiKey);
//     _initializeDatabase();
//   }

//   Future<void> _initializeDatabase() async {
//     final dbPath = await _getDatabasePath();
//     database = ChatDatabase(dbPath);
//     await database.init();
//     final messages = await database.getAllMessages();
//     setState(() {
//       _messages.addAll(messages);
//     });
//   }

//   Future<String> _getDatabasePath() async {
//     final directory = await getApplicationDocumentsDirectory();
//     return path.join(directory.path, 'chat_database.db');
//   }

//   Future<void> sendMessage() async {
//     final message = _userMessage.text.trim();
//     if (message.isEmpty) return;
//     _userMessage.clear();

//     setState(() {
//       final newMessage =
//           Message(isUser: true, message: message, date: DateTime.now());
//       _messages.add(newMessage);
//       database.insertMessage(newMessage);
//     });

//     final content = [Content.text(message)];
//     final response = await model.generateContent(content);
//     setState(() {
//       final botResponse = Message(
//         isUser: false,
//         message: response.text ?? "",
//         date: DateTime.now(),
//       );
//       _messages.add(botResponse);
//       database.insertMessage(botResponse);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Gemini Chat Bot'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 return Messages(
//                   isUser: message.isUser,
//                   message: message.message,
//                   date: DateFormat('HH:mm').format(message.date),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 15,
//                   child: TextFormField(
//                     controller: _userMessage,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(50),
//                       ),
//                       label: const Text("Your message"),
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   padding: const EdgeInsets.all(15),
//                   iconSize: 30,
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(Colors.black),
//                     foregroundColor: MaterialStateProperty.all(Colors.white),
//                     shape: MaterialStateProperty.all(
//                       const CircleBorder(),
//                     ),
//                   ),
//                   onPressed: sendMessage,
//                   icon: const Icon(Icons.send),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class Messages extends StatelessWidget {
//   final bool isUser;
//   final String message;
//   final String date;
//   const Messages({
//     Key? key,
//     required this.isUser,
//     required this.message,
//     required this.date,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
//         left: isUser ? 100 : 10,
//         right: isUser ? 10 : 100,
//       ),
//       decoration: BoxDecoration(
//         color: isUser
//             ? const Color.fromARGB(255, 9, 48, 79)
//             : Colors.grey.shade300,
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(10),
//           bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
//           topRight: const Radius.circular(10),
//           bottomRight: isUser ? Radius.zero : const Radius.circular(10),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             message,
//             style: TextStyle(color: isUser ? Colors.white : Colors.black),
//           ),
//           Text(
//             date,
//             style: TextStyle(color: isUser ? Colors.white : Colors.black),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Message {
//   final bool isUser;
//   final String message;
//   final DateTime date;

//   const Message({
//     required this.isUser,
//     required this.message,
//     required this.date,
//   });
// }

// class ChatDatabase {
//   late final String _path;
//   late Database _database;

//   ChatDatabase(String path) {
//     _path = path;
//   }

//   Future<void> init() async {
//     _database = await openDatabase(
//       _path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute(
//           'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, isUser INTEGER, message TEXT, date TEXT)',
//         );
//       },
//     );
//   }

//   Future<void> insertMessage(Message message) async {
//     await _database.insert(
//       'messages',
//       {
//         'isUser': message.isUser ? 1 : 0,
//         'message': message.message,
//         'date': message.date.toIso8601String(),
//       },
//     );
//   }

//   Future<List<Message>> getAllMessages() async {
//     final List<Map<String, dynamic>> maps = await _database.query('messages');
//     return List.generate(maps.length, (i) {
//       return Message(
//         isUser: maps[i]['isUser'] == 1,
//         message: maps[i]['message'],
//         date: DateTime.parse(maps[i]['date']),
//       );
//     });
//   }
// }





// import 'package:syncfusion_flutter_calendar/calendar.dart';

// class MyCalendar extends StatefulWidget {
//   const MyCalendar({Key? key}) : super(key: key);

//   @override
//   _MyCalendarState createState() => _MyCalendarState();
// }

// class _MyCalendarState extends State<MyCalendar> {
//   List<Appointment> _appointments = <Appointment>[];
//   bool problem = false;
//   String answer = '';

//   void _handleTapDate(DateTime date) {
//     List<Appointment> appointments = _appointments;
//     bool add = true;

//     for (int i = 0; i < appointments.length; i++) {
//       if (date == appointments[i].startTime) {
//         add = false;
//         break;
//       }
//     }

//     // Определяем периодичность для месячных (28 дней)
//     const cycleLength = 28;

//     if (add) {
//       // Проверяем, были ли уже добавлены месячные в текущий день или в ближайшие два дня
//       bool hasExisting = false;
//       for (int i = 0; i < appointments.length; i++) {
//         int diff = date.difference(appointments[i].startTime).inDays;
//         if (diff >= 0 && diff <= 2 * cycleLength) {
//           hasExisting = true;
//           break;
//         }
//       }

//       // Если месячные в этот период еще не были добавлены, добавляем их
//       if (!hasExisting) {
//         appointments.add(
//           Appointment(
//             startTime: date,
//             endTime: date,
//             color: Colors.purple,
//           ),
//         );

//         // Добавляем месячные с учетом задержек на 2 дня вперед
//         for (int i = 1; i <= 2; i++) {
//           DateTime nextDate = date.add(Duration(days: cycleLength + i));
//           appointments.add(
//             Appointment(
//               startTime: nextDate,
//               endTime: nextDate,
//               color: Colors.purple,
//             ),
//           );
//         }
//       }
//     } else {
//       // Удаляем месячные из текущего дня и ближайших двух дней
//       for (int i = 0; i < appointments.length; i++) {
//         int diff = date.difference(appointments[i].startTime).inDays;
//         if (diff >= 0 && diff <= 2 * cycleLength) {
//           appointments.removeAt(i);
//           i--; // Уменьшаем индекс, чтобы не пропустить следующий элемент
//         }
//       }
//     }

//     setState(() {
//       _appointments = appointments;
//     });
//   }

//   @override
//   Scaffold build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton:
//           ElevatedButton(onPressed: () {}, child: const Text('Check')),
//       body: SafeArea(
//         child: SfCalendar(
//           view: CalendarView.month,
//           firstDayOfWeek: 1,
//           dataSource: _getCalendarDataSource(_appointments),
//           todayHighlightColor: Colors.purpleAccent,
//           monthCellBuilder:
//               (BuildContext buildContext, MonthCellDetails details) {
//             return Container(
//               decoration: BoxDecoration(
//                   color: Colors.purple[100],
//                   border: Border.all(color: Colors.purpleAccent, width: 4)),
//               child: Center(
//                   child: Text(
//                 details.date.day.toString(),
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               )),
//             );
//           },
//           onTap: (CalendarTapDetails details) {
//             DateTime date = details.date!;
//             _handleTapDate(date);
//           },
//         ),
//       ),
//     );
//   }
// }

// _AppointmentDataSource _getCalendarDataSource(appointments) {
//   return _AppointmentDataSource(appointments);
// }

// class _AppointmentDataSource extends CalendarDataSource {
//   _AppointmentDataSource(List<Appointment> source) {
//     appointments = source;
//   }
// }




// import 'objectbox.g.dart';
// import 'package:custom_calendar_viewer/custom_calendar_viewer.dart';
// import 'package:objectbox/objectbox.dart';

// @Entity()
// class castratedRangeDate {
//   @Id(assignable: true)
//   int id = 0;

//   DateTime start;
//   DateTime end;

//   castratedRangeDate({
//     required this.start,
//     required this.end,
//   });
// }

// class ObjectBox {
//   late final Store store;
//   late final Box<castratedRangeDate> rangeDateBox;

//   ObjectBox._init(this.store) {
//     rangeDateBox = Box<castratedRangeDate>(store);
//   }

//   static Future<ObjectBox> init() async {
//     final store = await openStore();
//     return ObjectBox._init(store);
//   }

//   Future<void> saveRangesListCopy(List<RangeDate> rangeDateList) async {
//     await rangeDateBox.removeAll();

//     for (var rangeDate in rangeDateList) {
//       await rangeDateBox
//           .put(castratedRangeDate(start: rangeDate.start, end: rangeDate.end));
//     }
//   }

//   Future<List<RangeDate>> getAllRangeDates() async {
//     List<RangeDate> rangeDateList = [];
//     for (castratedRangeDate crd in rangeDateBox.getAll()) {
//       rangeDateList.add(RangeDate(start: crd.start, end: crd.end));
//     }
//     return rangeDateList;
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_application_3/objectbox_convert.dart';

// late ObjectBox objectBox;

// Future main() async {
//   objectBox = await ObjectBox.init();
//   runApp(const MyCalendar());
// }

// class MyCalendar extends StatelessWidget {
//   const MyCalendar({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffffffff)),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Calendar'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   String local = 'en';
//   List<RangeDate> ranges = [];

//   @override
//   void initState() {
//     super.initState();
//     loadRanges();
//   }

//   Future<void> loadRanges() async {
//     objectBox = await ObjectBox.init(); // Remove the type declaration
//     List<RangeDate> r = await objectBox.getAllRangeDates();
//     setState(() {
//       ranges = r;
//     });
//   }
