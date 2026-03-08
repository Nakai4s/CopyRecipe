import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/screens/add_url_screen.dart';
import 'package:copy_recipe/screens/recipe_screen.dart';
import 'package:copy_recipe/widgets/recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _switchToRecipeList() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final videoLists = ref.watch(videoProvider);

    final recipeListBody = videoLists.isNotEmpty
        ? ListView.builder(
            itemCount: videoLists.length,
            itemBuilder: (context, index) {
              final Video video = videoLists[index];
              return RecipeTile(
                video: video,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeScreen(video: video),
                    ),
                  );
                },
              );
            },
          )
        : Container(
            alignment: Alignment.center,
            child: const Text('Youtubeの料理動画または再生リストを追加してください'),
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          recipeListBody,
          AddUrlScreen(onAdded: _switchToRecipeList),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'レシピ一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_link),
            label: 'URL追加',
          ),
        ],
      ),
    );
  }
}
