import 'dart:io';

import 'package:flutter_so_me/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_so_me/managers/encryption_manager.dart' as encrypter;
import 'package:flutter_so_me/logs/log.dart';

class AuthManager with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  final FileUploadService _fileUploadService = FileUploadService();
  String _message = '';
  bool _isLoading = false;

  final CollectionReference<Map<String, dynamic>> _userCollection =
      _firebaseFirestore.collection("users");

  String get message => _message; //getter
  bool get isLoading => _isLoading; //getter

  setMessage(String message) {
    //setter
    _message = message;
    log(message);
    notifyListeners();
  }

  setIsLoading(bool loading) {
    //setter
    _isLoading = loading;
    notifyListeners();
  }

  //email, password
  Future<bool> createNewUser(
      {required String name,
      required String email,
      required String password,
      required File imageFile}) async {
    setIsLoading(true);
    bool isCreated = false;
    await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredential) async {
      String? photoUrl = await _fileUploadService.uploadFile(
          file: imageFile, userUid: userCredential.user!.uid);

      if (photoUrl != null) {
        await _userCollection.doc(userCredential.user!.uid).set({
          "name": encrypter.encryptData(name),
          "email": encrypter.encryptData(email),
          "picture": encrypter.encryptData(photoUrl),
          "createdAt": FieldValue.serverTimestamp(),
          "user_id": userCredential.user!.uid
        });
        isCreated = true;
      } else {
        setMessage('Image upload failed, reset and try again.');
        isCreated = false;
      }
      setIsLoading(false); //set to false
    }).catchError((onError) {
      setMessage('$onError');
      isCreated = false;
      setIsLoading(false); //set to false
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isCreated = false;
      setIsLoading(false); //set to false
    });
    return isCreated;
  }

  Future<bool> loginUser(
      {required String email, required String password}) async {
    bool isSuccessful = false;
    await _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((userCredential) {
      if (userCredential.user != null) {
        isSuccessful = true;
      } else {
        isSuccessful = false;
        setMessage('Could not log you in!');
      }
    }).catchError((onError) {
      setMessage('$onError');
      isSuccessful = false;
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isSuccessful = false;
    });
    return isSuccessful;
  }

  Future<bool> sendResetLink(String email) async {
    bool isSent = false;
    await _firebaseAuth.sendPasswordResetEmail(email: email).then((_) {
      isSent = true;
    }).catchError((onError) {
      setMessage('$onError');
      isSent = false;
    }).timeout(const Duration(seconds: 60), onTimeout: () {
      setMessage('Please check your internet connection.');
      isSent = false;
    });
    return isSent;
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
