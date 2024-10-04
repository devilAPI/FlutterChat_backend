import 'package:flutter/material.dart';
import 'package:owee/LoginScreen.dart';
import 'ChatScreen.dart';

class HomeScreen extends StatefulWidget {
  final String username; // Store the logged-in username

  HomeScreen({required this.username}); // Constructor to receive username

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController encryptionKeyController = TextEditingController();

  get username => this.username;

  void startChat() {
    String recipientId = recipientController.text;
    String encryptionKey = encryptionKeyController.text;

    if (recipientId.isNotEmpty && encryptionKey.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            userId: widget.username,
            encryptionKey: encryptionKey,
            recipientId: recipientId, // This should be the input from the user
          ),
        ),
      );


    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter recipient ID and encryption key')),
      );
    }
  }

  void logout() {
    // Navigate back to login screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Home')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: recipientController,
              decoration: InputDecoration(labelText: 'Recipient ID'),
            ),
            TextField(
              controller: encryptionKeyController,
              decoration: InputDecoration(labelText: 'Encryption Key'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: startChat,
              child: Text('Start Chat'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
