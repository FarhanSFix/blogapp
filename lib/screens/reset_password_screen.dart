import 'package:blogapp/constant.dart';
import 'package:flutter/material.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController txtEmail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 8),
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
              validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
              decoration: kInputDecoration('Email'),
            ),
            SizedBox(height: 20),
            kTextButton('Reset', () {}),
          ],
        ),
      ),
    );
  }
}
