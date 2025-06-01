import 'package:blogapp/screens/post_screen.dart';
import 'package:blogapp/screens/profile.dart';
import 'package:blogapp/services/user_service.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'post_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: currentIndex == 0 ? PostScreen() : Profile(),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostForm(title: 'Add new post'),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue.shade100,
          elevation: 3,
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
              ),
              SizedBox(width: 48),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: currentIndex == 1 ? Colors.blue : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
