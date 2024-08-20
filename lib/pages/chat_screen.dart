import 'package:flutter/material.dart';
import 'package:gemini_chatbot/pages/logout_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/message.dart';
import '../models/messages.dart';
import '../utils/size.dart';
import '../utils/style.dart';
import 'login_screen.dart'; // Import your login screen for navigation after logout
import 'feedback_screen.dart'; // Import the feedback screen

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userMessage = TextEditingController();
  bool isLoading = false;

  static const apiKey = "AIzaSyDIG-JhAjoTJPZV_M5CGzjhIX8klNbXm3I";

  final List<Message> _messages = [];

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  User? user = FirebaseAuth.instance.currentUser;

  void sendMessage() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _messages.add(Message(
        isUser: true,
        message: message,
        date: DateTime.now(),
      ));
      isLoading = true;
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);

    setState(() {
      _messages.add(Message(
        isUser: false,
        message: response.text ?? "",
        date: DateTime.now(),
      ));
      isLoading = false;
    });
  }

  void onAnimatedTextFinished() {
    setState(() {
      isLoading = false;
    });
  }

  void _navigateToLogoutScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogoutScreen()),
    );
  }

  void _handleMessageTap(Message message) {
    if (message.isUser) {
      _userMessage.text = message.message;
    } else {
      setState(() {
        _messages.remove(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: background,
        title: Text('Companion Bot',
            style:
                GoogleFonts.poppins(color: white, fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Options',
                    style: GoogleFonts.poppins(
                      color: white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (user != null) // Check if user is not null
                    Text(
                      user!.email ?? 'No email available',
                      style: GoogleFonts.poppins(
                        color: white,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('Feedback'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _navigateToLogoutScreen(); // Navigate to the logout screen
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Messages(
                  isUser: message.isUser,
                  message: message.message,
                  date: DateFormat('HH:mm').format(message.date),
                  onAnimatedTextFinished: onAnimatedTextFinished,
                  onTap: () => _handleMessageTap(message),
                );
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: medium, vertical: small),
            child: TextFormField(
              maxLines: 6,
              minLines: 1,
              controller: _userMessage,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(medium, 0, small, 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(xlarge),
                ),
                hintText: 'Enter prompt',
                hintStyle: hintText,
                suffixIcon: GestureDetector(
                  onTap: () {
                    if (!isLoading && _userMessage.text.isNotEmpty) {
                      sendMessage();
                    }
                  },
                  child: isLoading
                      ? Container(
                          width: medium,
                          height: medium,
                          margin: const EdgeInsets.all(xsmall),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(white),
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward,
                          color: _userMessage.text.isNotEmpty
                              ? Colors.white
                              : const Color(0x5A6C6C65),
                        ),
                ),
              ),
              style: promptText,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
