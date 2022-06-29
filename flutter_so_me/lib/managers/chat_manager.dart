import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_so_me/logs/log.dart';
import 'package:flutter_so_me/managers/encryption_manager.dart' as encrypter;

class ChatManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _chatroomCollection =
      _firebaseFirestore.collection("Chatrooms");
  final CollectionReference<Map<String, dynamic>> _userCollection =
      _firebaseFirestore.collection("users");

  String _message = '';

  String get message => _message; //getter

  setMessage(String message) {
    //setter
    _message = message;
    log(message);
    notifyListeners();
  }

  Future<bool> submitChat({required String? message}) async {
    bool isSubmitted = false;

    String userUid = _firebaseAuth.currentUser!.uid;
    FieldValue timeStamp = FieldValue.serverTimestamp();

    if (message != null) {
      await _chatroomCollection.doc().set({
        "user_uid": encrypter.encryptData(userUid),
        "timestamp": encrypter.encryptData(timeStamp.toString()),
        "message": encrypter.encryptData(message)
      }).then((_) {
        isSubmitted = true;
        setMessage('Message sent');
      }).catchError((onError) {
        isSubmitted = false;
        setMessage('$onError');
      }).timeout(const Duration(seconds: 60), onTimeout: () {
        isSubmitted = false;
        setMessage('Please check your internet connection');
      });
    } else {
      isSubmitted = false;
      setMessage('Message failed to send');
    }
    return isSubmitted;
  }

  String getCurrentUser() {
    return _firebaseAuth.currentUser!.uid;
  }

  /// Get all chats from the db
  Stream<QuerySnapshot<Map<String, dynamic>?>> getAllChats() {
    var data = _chatroomCollection.snapshots();
    return data;
  }

  ///get user info from db
  Future<Map<String, dynamic>?> getUserInfo(String userUid) async {
    Map<String, dynamic>? userData;
    await _userCollection
        .doc(userUid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> doc) {
      if (doc.exists) {
        userData = doc.data();
      } else {
        userData = null;
      }
    });
    return userData;
  }
}
