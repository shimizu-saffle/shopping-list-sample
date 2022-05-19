import 'package:cloud_firestore/cloud_firestore.dart';

extension FirebaseFirestoreX on FirebaseFirestore {
  // TODO(shimizu-saffle): withConverterを使ってリファクタリングする
  CollectionReference<Map<String, dynamic>> usersListRef(String userId) =>
      collection('lists').doc(userId).collection('userList');
}
