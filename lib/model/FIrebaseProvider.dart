import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// ChangeNotifierは、class内の値が変更した場合に知らせる機能を付与するという意味
class FirebaseProvider extends ChangeNotifier {
  // DateTimeを収録する変数.
  final now = DateTime.now();
  // Firestoreにアクセスするための変数.
  final docRef = FirebaseFirestore.instance.collection('posts');

  // Firestoreにデータを追加するメソッド.
  Future<void> addPost(String postC) async {
    await docRef.add({
      'post': postC,
      'createdAt': Timestamp.fromDate(now),
    });
    // ChangeNotifierを使用しているclassに使用できる関数、値が変わったことを他のページにも知らせて更新させる役目をもっている
    notifyListeners();
  }

  // Firestoreのデータを更新するメソッド.
  Future<void> updatePost(dynamic document, String postC) async {
    await docRef.doc(document.id).update({
      'post': postC,
      'updatedAt': Timestamp.fromDate(now),
    });
    notifyListeners();
  }

  // Firestoreのデータを削除するメソッド.
  Future<void> deletePost(dynamic document) async {
    await docRef.doc(document.id).delete();
    notifyListeners();
  }
}
