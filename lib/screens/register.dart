import 'package:blogapp/models/api_response.dart';
import 'package:blogapp/models/user.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'login.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _registerUser() async {
    ApiResponse response = await register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${response.error}')),
      );
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Login()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.green,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          text: 'Reg',
                          style: TextStyle(
                            fontFamily: 'Caudex',
                            fontSize: 50,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                          children: [
                            TextSpan(
                              text: 'ister',
                              style: TextStyle(
                                fontFamily: 'Caudex',
                                fontSize: 50,
                                fontWeight: FontWeight.w900,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildLabel('Name'),
                      _buildInputField(
                        nameController,
                        'Name',
                        validator: (val) => val!.isEmpty ? 'Invalid name' : null,
                      ),
                      _buildLabel('Email'),
                      _buildInputField(
                        emailController,
                        'Email',
                        inputType: TextInputType.emailAddress,
                        validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
                      ),
                      _buildLabel('Password'),
                      _buildInputField(
                        passwordController,
                        'Password',
                        obscureText: _obscurePassword,
                        validator: (val) => val!.length < 6 ? 'Minimum 6 characters' : null,
                        toggleVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      _buildLabel('Confirm Password'),
                      _buildInputField(
                        passwordConfirmController,
                        'Confirm Password',
                        obscureText: _obscureConfirmPassword,
                        validator: (val) => val != passwordController.text ? 'Passwords do not match' : null,
                        toggleVisibility: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                      const SizedBox(height: 25),
                      loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.blue[800],
                                ),
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    setState(() => loading = true);
                                    _registerUser();
                                  }
                                },
                                child: const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                      const SizedBox(height: 20),
                      kLoginRegisterHint('Already have an account? ', 'Login', () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => Login()),
                          (route) => false,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText, {
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    VoidCallback? toggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }
}
