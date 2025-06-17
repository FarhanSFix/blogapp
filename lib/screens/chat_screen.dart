import 'dart:convert';

import 'package:blogapp/constant.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String username;
  final String lastMsg;
  final int receiverId;

  const ChatScreen({
    required this.username,
    required this.lastMsg,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int? myId;

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [];

  Color getRandomColor(String text) {
    final hash = text.codeUnits.fold(0, (a, b) => a + b);
    final r = (hash * 123) % 255;
    final g = (hash * 321) % 255;
    final b = (hash * 213) % 255;
    return Color.fromARGB(255, r, g, b);
  }

  String _formatDateHeader(String isoDate) {
    final date = DateTime.tryParse(isoDate)?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) {
      return 'Hari Ini';
    } else if (msgDate == today.subtract(Duration(days: 1))) {
      return 'Kemarin';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _formatTime(String isoTime) {
    final dateTime = DateTime.tryParse(isoTime)?.toLocal();
    if (dateTime == null) return '';
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> getMyId() async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseURL/user'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    print('GET /user status: ${res.statusCode}');
    print('RESPONSE: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body); // ambil response body
      final user = data['user']; // ambil isi key "user"
      setState(() {
        myId = user['id']; // ambil id dari dalam user
      });
      print("My ID set to: $myId");
    } else {
      throw Exception('Gagal mengambil user info');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(int receiverId) async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseURL/messages/$receiverId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data
          .map<Map<String, dynamic>>(
            (m) => {
              'sender': m['sender_id'],
              'message': m['message'],
              'created_at': m['created_at'],
            },
          )
          .toList();
    } else {
      throw Exception('Gagal memuat pesan');
    }
  }

  Future<void> sendMessageToServer(String message, int receiverId) async {
    String token = await getToken();
    final response = await http.post(
      Uri.parse('$baseURL/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'receiver_id': receiverId, 'message': message}),
    );

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim pesan');
    }
  }

  @override
  void initState() {
    super.initState();
    initChat(); // eksekusi fungsi saat screen dimulai
  }

  Future<void> initChat() async {
    await getMyId(); // Tunggu sampai myId berhasil diambil

    // Pastikan myId sudah bukan null
    if (myId != null) {
      final messages = await getMessages(widget.receiverId);

      setState(() {
        _chatMessages.addAll(messages);
      });
    } else {
      print("Gagal mendapatkan myId");
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      final msg = _controller.text.trim();
      final now = DateTime.now().toIso8601String(); // waktu lokal saat ini

      setState(() {
        _chatMessages.add({
          'sender': myId,
          'message': msg,
          'created_at': now, // tambahkan ini untuk menghindari null
        });
        _controller.clear();
      });

      try {
        await sendMessageToServer(msg, widget.receiverId);
      } catch (e) {
        print("Error kirim pesan: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: getRandomColor(widget.username),
                child: Text(
                  widget.username.isNotEmpty
                      ? widget.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.username,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = _chatMessages[index];
                    final isMe = msg['sender'] == myId;
                    final currentDate = msg['created_at'];
                    final currentDateOnly = currentDate?.substring(0, 10);

                    String? previousDate;
                    if (index > 0) {
                      previousDate = _chatMessages[index - 1]['created_at']
                          ?.substring(0, 10);
                    }

                    List<Widget> messageWidgets = [];

                    if (index == 0 || previousDate != currentDateOnly) {
                      messageWidgets.add(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatDateHeader(currentDate),
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    messageWidgets.add(
                      _buildMessageBubble(
                        msg['message'],
                        isMe,
                        msg['created_at'] ?? '',
                      ),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: messageWidgets,
                    );
                  },
                ),
              ),

              Divider(height: 1),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
            bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(time),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
