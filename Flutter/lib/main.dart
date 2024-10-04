import 'package:flutter/material.dart';
import 'package:owee/LoginScreen.dart';
import 'HomeScreen.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: LoginScreen(),
    );
  }
}
