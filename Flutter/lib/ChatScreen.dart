import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String userId; // The ID of the current user
  final String encryptionKey;
  final String recipientId; // The ID of the chat recipient

  ChatScreen({required this.userId, required this.encryptionKey, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  List<Message> messages = []; // List to store messages

  @override
  void initState() {
    super.initState();
    retrieveMessages(); // Load previous messages when the screen initializes
  }

  Future<void> retrieveMessages() async {
    try {
      // Die URL wird aktualisiert, um den encryptionKey hinzuzufügen
      final response = await http.get(Uri.parse(
          'http://yourserver/retrieve.php?user1Id=${widget.userId}&user2Id=${widget.recipientId}&encryptionKey=${widget.encryptionKey}')); // Hier wird angenommen, dass widget.userId den encryptionKey darstellt.

      // Log the response body for debugging
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if 'messages' key exists and is a list
        if (jsonResponse.containsKey('messages') && jsonResponse['messages'] is List) {
          setState(() {
            messages = (jsonResponse['messages'] as List).map((msg) => Message(
              msg['senderId'], // Ensure this key matches the one in your PHP response
              msg['message'],
              DateTime.parse(msg['timestamp']),
            )).toList();
          });
        } else {
          print('Error: Messages key not found or not a list');
          print(jsonResponse); // Log the entire response for debugging
        }
      } else {
        print('Error retrieving messages: ${response.body}');
      }
    } catch (e) {
      print('Error retrieving messages: $e');
    }
  }



  String encryptMessage(String message) {
    final key = encrypt.Key.fromUtf8(widget.encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.encrypt(message, iv: iv).base64; // Encrypt and return as Base64
  }

  void sendMessage() async {
    String message = messageController.text;
    if (message.isNotEmpty) {
      String encryptedMessage = encryptMessage(message);
      try {
        final response = await http.post(
          Uri.parse('http://yoursever/save.php'),
          body: {
            'user1Id': widget.userId, // ID des sendenden Benutzers
            'user2Id': widget.recipientId, // ID des empfangenden Benutzers
            'message': encryptedMessage, // Verschlüsselter Nachrichtentext
            'encryptionKey': widget.encryptionKey, // Verschlüsselungsschlüssel
          },
        );

        if (response.statusCode == 200) {
          setState(() {
            messages.add(Message(widget.userId, encryptedMessage, DateTime.now()));
          });
          messageController.clear();
        } else {
          print('Failed to send message: ${response.body}');
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }



  String decryptMessage(String encryptedMessage) {
    final key = encrypt.Key.fromUtf8(widget.encryptionKey.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    return encrypter.decrypt64(encryptedMessage, iv: iv); // Decrypt the message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.recipientId}')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: messages[index],
                  currentUserId: widget.userId,
                  isEncrypted: true,
                  decryptMessage: decryptMessage,
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(labelText: 'Message'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Message {
  final String sender_Id; // ID of the sender
  final String text; // Message text
  final DateTime timestamp; // Timestamp of the message

  Message(this.sender_Id, this.text, this.timestamp);
}

class MessageBubble extends StatelessWidget {
  final Message message; // The message to be displayed
  final String currentUserId; // Current user's ID
  final bool isEncrypted; // Flag to check if the message is encrypted
  final String Function(String) decryptMessage; // Function to decrypt messages

  MessageBubble({
    required this.message,
    required this.currentUserId,
    required this.isEncrypted,
    required this.decryptMessage,
  });

  @override
  Widget build(BuildContext context) {
    bool isSender = message.sender_Id == currentUserId; // Check if the current user is the sender

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isEncrypted ? decryptMessage(message.text) : message.text, // Decrypt if necessary
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
