import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../models/recipe_model.dart';

/// ホーム画面に表示するレシピリスト
class RecipeTile extends StatelessWidget {
  final Video video;

  const RecipeTile({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.red,
      child: Column(
        children: [
          Text(video.channelTitle, textAlign: TextAlign.left),
          Row(
            children: [
              // サムネイル画像
              Image(
                width: 150.0,
                image: NetworkImage(video.thumbnailUrl),
              ),
              const SizedBox(width: 5.0),
              // 動画タイトル              
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12.0,
                ),
                overflow: TextOverflow.clip,
              ),
            ]            
          ),
          const SizedBox(height: 12.0),
          // 概要欄
          Text(RecipeParts.extractRecipe(video.description).steps),
        ],
      ),
    );
  }

}