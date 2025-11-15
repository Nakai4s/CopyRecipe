import 'package:copy_recipe/models/video_model.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:hive/hive.dart";
import 'package:path_provider/path_provider.dart';

void main() async {
  // フラッターエンジンの初期化(非同期処理を行う前に必要)
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();

  // Hive設定
  Hive.init(appDir.path);
  Hive.registerAdapter(VideoAdapter());
  await Hive.openBox<Video>('Videos');

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}