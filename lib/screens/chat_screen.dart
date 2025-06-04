import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String lastMsg;
  final String username;
  const ChatScreen({required this.username, required this.lastMsg});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [];

  @override
  void initState() {
    if (widget.lastMsg.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _chatMessages.add({
            'sender': widget.username,
            'message': widget.lastMsg,
          });
        });
      });
    }

    super.initState();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add({'sender': 'me', 'message': _controller.text.trim()});
        _controller.clear();
      });
    }
    print(_chatMessages);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.username),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isMe = msg['sender'] == 'me';
                  return _buildMessageBubble(msg['message'], isMe);
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
    );
  }

  Widget _buildMessageBubble(String message, bool isMe) {
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
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
