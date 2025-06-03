import 'package:blogapp/screens/chat_screen.dart';

import 'package:flutter/material.dart';
import 'dart:math';

class DmScreen extends StatefulWidget {
  const DmScreen({super.key});

  @override
  State<DmScreen> createState() => _DmScreenState();
}

class _DmScreenState extends State<DmScreen> {
  final List<Map<String, String>> _messages = [
    {'name': 'Rian', 'lastMessage': 'otw banh!!', 'time': '12:00'},
    {'name': 'Nina', 'lastMessage': 'Lagi apa?', 'time': '11:30'},
    {'name': 'Dika', 'lastMessage': 'Thanks ya!', 'time': '10:45'},
  ];

  final List<String> _activeUsers = [
    'Rian',
    'Nina',
    'Dika',
    'Sita',
    'Raka',
    'Putri',
  ];

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Direct Message'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Active Now",
                style: TextStyle(
                  fontFamily: 'Caudex',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 90,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _activeUsers.length,
                itemBuilder: (context, index) {
                  String user = _activeUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: getRandomColor(),
                          child: Text(
                            user[0],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        SizedBox(height: 4),
                        Text(user, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(height: 1),
            // Daftar chat
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getRandomColor(),
                      child: Text(msg['name']![0]),
                    ),
                    title: Text(msg['name']!),
                    subtitle: Text(msg['lastMessage']!),
                    trailing: Text(msg['time']!),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(username: msg['name']!),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
