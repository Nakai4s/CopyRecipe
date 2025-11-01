import 'package:flutter/material.dart';
import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/services/api_service.dart';
import 'package:copy_recipe/models/recipe_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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

  /// URLから動画の概要欄を抽出する
  Future<String> extractDescriptionFromUrl(String url) async {
    final videoId = extractVideoId(url);
    return await APIService.instance.fetchVideoDescription(videoId);
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
        title: Text(
          'CopyRecipe',
          style: TextStyle(
            color: const Color(0xFFF8F3D9),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF504B38),
      ),
      body: Padding(        
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
                      _loadVideo();
                      _descriptionFuture = extractDescriptionFromUrl(_controller.text);
                      _videoFuture = extractVideoFromUrl(_controller.text);
                    });
                  }
                ),
              ),
            ), 
            const SizedBox(height: 12),
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
                  return _buildVideoInfo(video);
                },
              ),
            ), 
            const SizedBox(height: 12),
            // 概要欄
            Expanded(
              child: _playerController != null ? 
              FutureBuilder<String>(
                future: _descriptionFuture,                
                builder: (context, snapshot) {
                  // データの取得待ち
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // エラー取得
                  else if (snapshot.hasError) {
                    return Text('エラー: 不正なURLです${snapshot.error}');
                  }
                  // データ取得
                  else if (snapshot.hasData) {
                    String? afterRegExp = RecipeParts.extractRecipe(snapshot.data!).steps;
                    if(afterRegExp == '') afterRegExp = 'レシピを取得できませんでした。';
                    return SingleChildScrollView(
                      child: SelectableText(
                          afterRegExp,
                      ),
                    );
                  } else {
                    return const Text('ここに概要欄が表示されます');
                  }
                },
              )
              : Column(
                children: [
                  const Text('ここに概要欄が表示されます'),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  /// 動画の情報
  _buildVideoInfo(Video video) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      padding: const EdgeInsets.all(5.0),
      height: 150.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3D9),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // チャンネルのタイトル
          Text(video.channelTitle),
          const SizedBox(height: 5.0),
          Row(
            children: [
              // サムネイル画像
              Image(
                width: 150.0,
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
                )
              ),
            ],
          )          
        ],
      ),
    );
  }
}