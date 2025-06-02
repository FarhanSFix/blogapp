import 'dart:convert';

import 'package:blogapp/constant.dart';
import 'package:blogapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController txtEmail = TextEditingController();

  Future<void> verifyEmail() async {
    final res = await http.post(
      Uri.parse(resetPasswordURL),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': txtEmail.text}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      await Future.delayed(Duration(milliseconds: 200));
      showPasswordDialog(txtEmail.text);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? somethingWentWrong)),
      );
    }
  }

  void showPasswordDialog(String email) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buat Password Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              decoration: kInputDecoration('Password baru'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: kInputDecoration('Konfirmasi password'),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  "Batal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Password tidak cocok')));
                return;
              }

              if (newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Kolom Harus diisi')));
                return;
              }

              final res = await http.post(
                Uri.parse(confirmResetPasswordURL),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'email': email,
                  'password': newPasswordController.text,
                  'password_confirmation': confirmPasswordController.text,
                }),
              );

              final data = jsonDecode(res.body);
              Navigator.of(context).pop(); // tutup dialog

              if (res.statusCode == 200) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(data['message'])));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(data['message'] ?? somethingWentWrong),
                  ),
                );
              }
            },
            child: Container(
              width: 140,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Reset Password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: ListView(
          children: [
            RichText(
              text: TextSpan(
                text: 'Reset ',
                style: const TextStyle(
                  fontFamily: 'Caudex',
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
                children: [
                  TextSpan(
                    text: 'Password',
                    style: const TextStyle(
                      fontFamily: 'Caudex',
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
              decoration: kInputDecoration('Email'),
            ),
            SizedBox(height: 20),
            kTextButton('Reset', verifyEmail),
          ],
        ),
      ),
    );
  }
}
