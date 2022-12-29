import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _formKey = GlobalKey<FormState>();
  final _messageTextController = TextEditingController();
  String? _message;
  User? user;
  late DocumentSnapshot<Map<String, dynamic>> userData;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      user = FirebaseAuth.instance.currentUser;
      userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
    });
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (userData.data() == null) {
      userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
    }
    if (_message != null && _message!.trim().isNotEmpty) {
      // send message
      FirebaseFirestore.instance.collection('chats').add({
        'text': _message,
        'createdAt': Timestamp.now(),
        'userId': user!.uid,
        'userImage': userData.data()!['imageUrl'],
        'username': userData.data()!['username'],
      });
      _sendNotification(_message);
      _messageTextController.clear();
    }
  }

  void _sendNotification(message) async {
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAO_HkdNA:APA91bFToe5RFiPpMNw_wf6a_OXIiiZZxVcDhOMvJ0R_Q645VWWHghKRX5TjnfSfjPIARqX1zaYeCfa0UG3Crcb1tFIttSXktFKcw1jUEQs5JPTIkYAqxZnv9BYoUS7Cs766zBixIEyr',
    };
    final data = {
      "to": "/topics/flutterchat",
      "notification": {
        "title": 'Yangi xabar',
        "body": message,
      },
    };

    try {
      await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      // print(jsonDecode(response.body));
    } catch (e) {
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _messageTextController,
                decoration: const InputDecoration(
                  labelText: 'Xabar yuboring...',
                ),
                textCapitalization: TextCapitalization.sentences,
                onSaved: (value) {
                  _message = value;
                },
              ),
            ),
            IconButton(
              onPressed: _sendMessage,
              icon: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
