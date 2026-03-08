import 'package:copy_recipe/providers/video_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';

/// ホーム画面に表示するレシピウィジェット
class RecipeTile extends ConsumerWidget {
  final Video video;
  final VoidCallback onTap;

  const RecipeTile({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(videoProvider.notifier);
    
    return Dismissible(
      key: Key(video.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        notifier.deleteId(video.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${video.title} を削除しました')),
        );
      },
      child: Card(
        margin: EdgeInsets.all(5.0),
        color: Color(0xFFFFE8CD),
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              // サムネイル画像
              Image(
                width: 150,
                height: 84,
                fit: BoxFit.cover,
                image: NetworkImage(video.thumbnailUrl),
              ),
              const SizedBox(width: 5.0),
              // 動画タイトル
              Expanded(
                child: Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}