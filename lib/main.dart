import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_sample/model/FIrebaseProvider.dart';
import 'package:provider_sample/ui/app_page.dart';
import 'package:provider_sample/ui/start_page.dart';
import 'package:provider_sample/ui/stream_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        // 名前へ付きルートの設定をして、画面遷移のコードを短くする.
        '/': (context) => StartPage(), // 最初に表示されるページ.
        '/streamPage': (context) => StreamPage(), // リアルタイムにデータを表示するページ.
        '/appPage': (context) => AppPage(), // Firestoreにデータを追加するページ.
      },
    );
  }
}
