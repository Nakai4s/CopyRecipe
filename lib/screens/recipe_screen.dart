import 'package:copy_recipe/widgets/recipe_tile.dart';
import 'package:flutter/material.dart';
import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});
  @override
  _RecipeScreen createState() => _RecipeScreen();
}

class _RecipeScreen extends State<RecipeScreen> {

  // YouTubeのURLを入力するためのコントローラー
  final _controller = TextEditingController();
  Future<String>? _descriptionFuture;

  Future<Video>? _videoFuture;

  // 動画用コントローラー
  YoutubePlayerController? _playerController;

  /// URLから動画IDを抽出する
  String extractVideoId(String url) {
    final regex = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11}).*');
    final match = regex.firstMatch(url);
    return match != null ? match.group(1)! : '';
  }

  /// URLから動画を抽出する
  Future<Video> extractVideoFromUrl(String url) async {
    final videoId = extractVideoId(url);
    return await APIService.instance.fetchVideoFromId(videoId);
  }

  /// 動画を読み込む
  void _loadVideo() async {
    final url = _controller.text.trim();
    final videoId = extractVideoId(url);
    setState(() {
      _playerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBE5C2),
      appBar: AppBar(
        title: Text('CopyRecipe',
          style: TextStyle(
            color: const Color(0xFFF8F3D9),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF504B38),
      ),
      body: Container(        
        padding: const EdgeInsets.all(25.0),
        child: Column(          
          children: [
            const SizedBox(height: 12),
            // URL入力欄
            TextField(              
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'YouTubeのURLを貼り付けてください',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _videoFuture = extractVideoFromUrl(_controller.text);
                    });
                  }
                ),
              ),
            ), 
            const SizedBox(height: 12.0),
            SizedBox(
              child: FutureBuilder<Video>(
                future: _videoFuture, 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('エラー: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('動画が見つかりませんでした');
                  }

                  final video = snapshot.data!;
                  return RecipeTile(video: video);
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}