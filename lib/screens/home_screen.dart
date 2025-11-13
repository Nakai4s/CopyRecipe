import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/screens/recipe_screen.dart';
import 'package:copy_recipe/widgets/recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoLists = ref.watch(videoProvider);
    final notifier = ref.read(videoProvider.notifier);

    // 動画がない場合に表示するウィジェット
    final Container emptyWidget = Container(
      alignment: Alignment.center,
      child: Text(
        'Youtubeの料理動画または再生リストを追加してください'
      ),
    );

    // 動画リストのウィジェット
    ListView view = ListView.builder(
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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('CopyRecipe'),
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(5),
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: videoLists.isNotEmpty ? view : emptyWidget,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: CircleBorder(),
        onPressed: ()  {
          _showAddRecipeDialog(context, ref);
        },
        child: const Icon(Icons.add_link),
      ),
    );
  }

  // URLを入力するダイアログを表示
  Future<void> _showAddRecipeDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    String? url;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
                const SizedBox(height: 10),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  // setState(() {
                  //   url = titleController.text;
                  // });
                  url = titleController.text;
                  try {
                    ref.read(videoProvider.notifier).extractVideoFromUrl(url!);
                    Navigator.pop(context);
                  } catch(e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    Navigator.pop(context);
                  }
                },
                child: const Text('追加'),
              ),
            ],
          );
        });
      },
    );
  }
}