import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_sample/model/FIrebaseProvider.dart';

/// Firestoreにデータを追加するページ.
class AppPage extends StatelessWidget {
  const AppPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formに値を保存するTextEditingController.
    final TextEditingController postC = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('appPage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: postC, // フォームのデータをコントローラーがここで受け取る.
            ),
            ElevatedButton(
                onPressed: () {
                  // コントローラーで取得した値をFirestoreに追加する.
                  context.read<FirebaseProvider>().addPost(postC.text);
                },
                child: Text('Post')),
            ElevatedButton(
                onPressed: () {
                  // 前の画面に戻る.
                  Navigator.pop(context);
                },
                child: Text('戻る'))
          ],
        ),
      ),
    );
  }
}
