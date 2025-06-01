import 'package:blogapp/screens/loading.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    // Setelah 2 detik, pindah ke halaman Loading
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Loading()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Our',
                  style: const TextStyle(
                    fontFamily: 'Caudex',
                    fontSize: 50,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                  children: [
                    TextSpan(
                      text: 'Blog',
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'By Brother\'s Team',
                style: TextStyle(fontSize: 16, fontFamily: 'Caudex'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
