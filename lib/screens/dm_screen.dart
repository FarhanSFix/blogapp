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

  Color getRandomColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
    );
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

      // Simpan semua user (untuk FAB)
      _allUsers = List<Map<String, dynamic>>.from(data);

      List<Map<String, dynamic>> usersWithLastMsg = [];

      // Ambil ID pengguna saat ini agar tidak tampil di list
      _currentUserId = await getUserId();

      for (var user in data) {
        if (user['id'] == null || user['id'] == _currentUserId) continue;
        String lastMsg = await getLastMessage(user['id']);

        if (lastMsg.isNotEmpty) {
          usersWithLastMsg.add({
            'id': user['id'],
            'name': user['name'],
            'lastMsg': lastMsg,
          });
        }
      }

      setState(() {
        _activeUsers = usersWithLastMsg;
      });
    } else {
      print('Gagal ambil user aktif: ${res.statusCode}');
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

  Future<String> getLastMessage(int userId) async {
    final token = await getToken();
    final res = await http.get(
      Uri.parse('$baseURL/messages/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      if (data.isNotEmpty) {
        return data.last['message'] ?? '';
      }
    }
    return '';
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
        body: ListView.builder(
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.message),
          onPressed: () {
            // Aksi saat FAB ditekan, bisa nanti dibikin pilih user dari dialog atau ke halaman pilih user
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
        return ListView.builder(
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
        );
      },
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
                Navigator.pop(ctx); // Tutup dialog
                try {
                  await deleteConversation(userId);
                  // Refresh list
                  getUsers();
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
