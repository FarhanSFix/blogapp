import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/user.dart';
import 'package:blogapp/screens/reset_password_screen.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);

    FocusManager.instance.primaryFocus?.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => Home()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formkey,
        child: ListView(
          padding: EdgeInsets.all(32),
          children: [
            RichText(
              text: TextSpan(
                text: 'Log',
                style: const TextStyle(
                  fontFamily: 'Caudex',
                  fontSize: 50,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
                children: [
                  TextSpan(
                    text: 'In',
                    style: const TextStyle(
                      fontFamily: 'Caudex',
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: txtEmail,
              validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
              decoration: kInputDecoration('Email'),
            ),
            SizedBox(height: 20),
            Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: txtPassword,
              obscureText: true,
              validator: (val) =>
                  val!.length < 6 ? 'Required at least 6 chars' : null,
              decoration: kInputDecoration('Password'),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPassword()),
                  );
                },
                child: Text("Forgot Password?"),
              ),
            ),
            SizedBox(height: 10),
            loading
                ? Center(child: CircularProgressIndicator())
                : kTextButton('Login', () {
                    if (formkey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                        _loginUser();
                      });
                    }
                  }),
            SizedBox(height: 20),
            kLoginRegisterHint('Dont have an acount? ', 'Register', () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Register()),
                (route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }
}
