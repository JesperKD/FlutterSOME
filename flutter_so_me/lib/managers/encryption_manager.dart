import 'package:encrypt/encrypt.dart';

final key = Key.fromUtf8('iEeZkcEHceaZErC76FGDAQ6uUGsuAGWh'); //32 chars
final iv = IV.fromUtf8('HXGZx6isZIcvi2D7'); //16 chars

//encrypt
String encryptData(String text) {
  final e = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted_data = e.encrypt(text, iv: iv);
  return encrypted_data.base64;
}

//dycrypt
String decryptData(String text) {
  final e = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted_data = e.decrypt(Encrypted.fromBase64(text), iv: iv);
  return decrypted_data;
}
