import 'package:flutter/material.dart';
import '../models/video_model.dart';

/// ホーム画面に表示するレシピウィジェット
class RecipeTile extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const RecipeTile({
    super.key,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5.0),
      color: Color(0xFFFFE8CD),
      child: ListTile(
        title: Text(video.channelTitle, textAlign: TextAlign.left),
        subtitle: Row(
          children: [
            // サムネイル画像
            Image(
              width: 120.0,
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
        // 概要欄
        // Text(RecipeParts.extractRecipe(video.description).steps),
        onTap: onTap,
        
      ),
    );
  }

}