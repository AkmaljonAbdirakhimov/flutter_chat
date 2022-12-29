import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _getUserDetails(String userEmail, String userName, String userPassword,
      File? userImage, bool isLogin) async {
    UserCredential userCredential;
    setState(() {
      _isLoading = true;
    });
    try {
      if (isLogin) {
        // kirish
        userCredential = await _auth.signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );
      } else {
        // ro'yxatdan o'tish
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: userEmail,
          password: userPassword,
        );

        // ...
        final imagePath = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');
        await imagePath.putFile(userImage!);

        final imageUrl = await imagePath.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': userName,
          'email': userEmail,
          'imageUrl': imageUrl,
        });
      }
    } on FirebaseException catch (e) {
      var message =
          'Kechirasiz, ma\'lumotlarda xatolik. Qaytadan o\'rinib ko\'ring.';

      if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_getUserDetails, _isLoading),
    );
  }
}
