import 'dart:convert';

import 'package:blogapp/constant.dart';
import 'package:blogapp/screens/chat_screen.dart';
import 'package:blogapp/services/user_service.dart';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:http/http.dart' as http;

class DmScreen extends StatefulWidget {
  const DmScreen({super.key});

  @override
  State<DmScreen> createState() => _DmScreenState();
}

class _DmScreenState extends State<DmScreen> {
  List<Map<String, dynamic>> _activeUsers = [];
  List<Map<String, dynamic>> _allUsers = [];
  int? _currentUserId;
  bool _isLoading = true;

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    final date = DateTime.tryParse(isoDate)?.toLocal();
    if (date == null) return '';

    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString()}';
  }

  Future<void> getUsers() async {
    final token = await getToken();
    if (token == 'null') return;

    final res = await http.get(
      Uri.parse(usersURL),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      _allUsers = List<Map<String, dynamic>>.from(data);
      _currentUserId = await getUserId();

      List<Map<String, dynamic>> usersWithLastMsg = [];

      for (var user in data) {
        if (user['id'] == null || user['id'] == _currentUserId) continue;

        final lastMsgData = await getLastMessage(user['id']);
        final lastMsg = lastMsgData['message'];
        final createdAt = lastMsgData['created_at'];

        if (lastMsg.isNotEmpty) {
          usersWithLastMsg.add({
            'id': user['id'],
            'name': user['name'],
            'lastMsg': lastMsg,
            'created_at': createdAt,
          });
        }
      }

      usersWithLastMsg.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final dateB =
            DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });

      if (!mounted) return;
      setState(() {
        _activeUsers = usersWithLastMsg;
        _isLoading = false;
      });
    } else {
      print('Gagal ambil user aktif: ${res.statusCode}');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteConversation(int userId) async {
    final token = await getToken();
    final res = await http.delete(
      Uri.parse('$baseURL/messages/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      print('Percakapan berhasil dihapus');
      setState(() {
        _activeUsers.removeWhere((user) => user['id'] == userId);
      });
    } else {
      throw Exception('Gagal menghapus percakapan');
    }
  }

  Future<Map<String, dynamic>> getLastMessage(int userId) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseURL/messages/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        final lastMsg = data.last;
        return {
          'message': lastMsg['message'] ?? '',
          'created_at': lastMsg['created_at'] ?? '',
        };
      }
    }
    return {'message': '', 'created_at': ''};
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Direct Message'),
          backgroundColor: Colors.blueAccent,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _activeUsers.isEmpty
            ? Center(child: Text('Tidak ada percakapan.'))
            : RefreshIndicator(
                onRefresh: getUsers,
                child: ListView.builder(
                  itemCount: _activeUsers.length,
                  itemBuilder: (context, index) {
                    final user = _activeUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getRandomColor(),
                        child: Text(user['name'][0].toUpperCase()),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(
                        user['lastMsg'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        _formatDate(user['created_at']),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              username: user['name'],
                              lastMsg: '',
                              receiverId: user['id'],
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        _showDeleteDialog(context, user['id'], user['name']);
                      },
                    );
                  },
                ),
              ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.message),
          onPressed: () {
            _showUserSelectionDialog(context);
          },
        ),
      ),
    );
  }

  void _showUserSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pilih user untuk memulai chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: _allUsers.length,
                  itemBuilder: (context, index) {
                    final user = _allUsers[index];
                    if (user['id'] == _currentUserId)
                      return SizedBox(); // skip diri sendiri

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getRandomColor(),
                        child: Text(user['name'][0].toUpperCase()),
                      ),
                      title: Text(user['name']),
                      onTap: () {
                        Navigator.pop(ctx); // tutup bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              username: user['name'],
                              lastMsg: '',
                              receiverId: user['id'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  void _showDeleteDialog(BuildContext context, int userId, String username) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Hapus Percakapan'),
          content: Text('Yakin ingin menghapus percakapan dengan $username?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await deleteConversation(userId);
                  if (!mounted) return;
                  setState(() => _isLoading = true);

                  await getUsers();
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Percakapan dihapus')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menghapus: $e')),
                  );
                }
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
