import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_sample/model/FIrebaseProvider.dart';

/// StreamBuilderデータを表示.
/// 更新と削除を同じページで行う.
class StreamPage extends StatelessWidget {
  const StreamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formに値を保存するTextEditingController.
    final TextEditingController postC = TextEditingController();
    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('posts').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('GetApp'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream, //インスタンス化したクラスを代入した変数.
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
            //ListViewで画面に描画する.
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          // 編集用Modal
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: 400,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const Text('Modal BottomSheet'),
                                      TextFormField(
                                        controller: postC,
                                        decoration: const InputDecoration(
                                          border: UnderlineInputBorder(),
                                          labelText: '文字を入力してください',
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                          onPressed: () async {
                                            // データを更新する.
                                            context
                                                .read<FirebaseProvider>()
                                                .updatePost(
                                                    document, postC.text);
                                          },
                                          child: Text('編集')),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        child: const Text('閉じる'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () async {
                          // データを削除する.
                          context.read<FirebaseProvider>().deletePost(document);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
                // postsコレクションのpostフィールドを表示する.
                title: Text(data['post']),
              );
            }).toList(), //map()を使うときは必ず最後につける.
          );
        },
      ),
    );
  }
}
