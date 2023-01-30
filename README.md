# provider_sample
https://pub.dev/packages/provider

## 今回使用したProviderの書き方の翻訳

値の読み込み
値を読み取る最も簡単な方法は、[BuildContext]の拡張メソッドを使用することである。

context.watch<T>() は、ウィジェットが T の変更をリスニングするようにします。
context.read<T>() は、T をリスニングせずに返します。
context.select<T, R>(R cb(T value)), ウィジェットが T の一部だけを聞くことができるようにします．

静的メソッドの Provider.of<T>(context) も使用でき、これは watch と同様の動作をします。
listen パラメータが false に設定されている場合（Provider.of<T>(context, listen: false) のように）、read と同様の動作になります。
context.read<T>() は、値が変更されてもウィジェットを再構築しないので、StatelessWidget.build/State.build 内では呼び出せないことに注意する必要があります。
一方、これらのメソッドの外では、自由に呼び出すことができます。
これらのメソッドは、渡された BuildContext に関連付けられたウィジェットから始まるウィジェットツリーを検索し、見つかった T 型の最も近い変数を返す（または何も見つからなかったら投げる）。
この操作は O(1) です。ウィジェットツリーの中を歩く必要はない．
値を公開する最初の例と組み合わせると、このウィジェットは公開された String を読み込んで "Hello World" をレンダリングします。

```dart
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      // Don't forget to pass the type of the object you want to obtain to `watch`!
      context.watch<String>(),
    );
  }
}
```

マルチプロバイダ
大きなアプリケーションで多くの値を注入する場合、
Providerは急速にかなりネスト化する可能性があります。

```dart
Provider<Something>(
  create: (_) => Something(),
  child: Provider<SomethingElse>(
    create: (_) => SomethingElse(),
    child: Provider<AnotherThing>(
      create: (_) => AnotherThing(),
      child: someWidget,
    ),
  ),
),
```

To:
```dart
MultiProvider(
  providers: [
    Provider<Something>(create: (_) => Something()),
    Provider<SomethingElse>(create: (_) => SomethingElse()),
    Provider<AnotherThing>(create: (_) => AnotherThing()),
  ],
  child: someWidget,
)
```

どちらの例も動作は厳密には同じです。MultiProviderはコードの外観を変えるだけです。

------

# 今回作成したサンプル
- 過去にGetXで書いたサンプルをリファクタリングしたもの
    - アーキテクチャー（設計）
    - 全体にアクセスできるMultiProviderを使用.
        - Riverpod開発の参考になったcontext.watch()とかを使う.
        - Riverpodに慣れているとわかりやすかった.


**pubspec.yamlに以下のpackageを追加**
```yaml
provider: ^6.0.5
firebase_core: ^2.4.1
cloud_firestore: ^4.3.1
```

## ChangeNotifier class
**公式のリンク**
https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html

通知用に VoidCallback を使用した変更通知 API を提供する、拡張や混在が可能なクラスです。
リスナーの追加に O(1) 、リスナーの削除と通知のディスパッチに O(N) (Nはリスナーの数) を実現しています。

わかりやすくいうと、Providerがイベントが起きると、変更を検知してメソッドが呼ばれるという仕組み。
notifyListeners()は、イベントが起きるまで呼ばれない!

## ProviderとFirebaseを使う設定
MultiProviderを設定する。
Firebaseをアプリで使う設定をmain関数にする.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    /// プロバイダは[MyApp]の内部ではなく、その上に配置されます。
    /// プロバイダをモックしながら、[MyApp] を使うことができます。
    /// この書き方だと、ネストしていく書き方になるのを防げる!
    /// 正しこの中に、Providerのクラスが増えていく!
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Firestoreを操作するProvider.
データの追加・更新・削除を行う.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ChangeNotifierは、class内の値が変更した場合に知らせる機能を付与するという意味
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
      'createdAt': Timestamp.fromDate(now),
    });
    notifyListeners();
  }

  // Firestoreのデータを削除するメソッド.
  Future<void> deletePost(dynamic document) async {
    await docRef.doc(document.id).delete();
    notifyListeners();
  }
}
```
