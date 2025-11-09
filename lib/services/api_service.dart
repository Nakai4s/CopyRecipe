import 'dart:convert';
import 'dart:io';
import 'package:copy_recipe/models/video_model.dart';
import 'package:http/http.dart' as http;
import 'package:copy_recipe/utilities/keys.dart';

/// YoutubeAPI機能クラス
class APIService {

  APIService._instantiate();
  static final APIService instance = APIService._instantiate();
  
  final String _baseUrl = 'www.googleapis.com';

  /// YouTubeのURLが「動画」または「再生リスト」かどうかを検証する
  bool isValidYoutubeUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    // ホストが youtube.com または youtu.be であること
    final hostValid = uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
    if (!hostValid) return false;

    final path = uri.path;

    // 動画URLパターン
    final isWatch = uri.path == '/watch' && uri.queryParameters.containsKey('v');
    final isShortLink = uri.host == 'youtu.be' && path.length >= 12; // /VIDEO_ID形式
    final isPlaylistItem = uri.queryParameters.containsKey('list');

    // 再生リストURLパターン
    final isPlaylist = path == '/playlist' && uri.queryParameters.containsKey('list');

    // 除外対象（チャンネルやショート動画など）
    final isChannel = path.startsWith('/channel/');
    final isUser = path.startsWith('/user/');
    final isHandle = path.startsWith('/@');
    final isShorts = path.startsWith('/shorts/');

    if (isChannel || isUser || isHandle || isShorts) return false;

    // 動画 or プレイリストならOK
    return isWatch || isShortLink || isPlaylist || isPlaylistItem;
  }


  Future<Video> fetchVideoFromId(String id) async {
    final parameters = {
      'part': 'snippet',
      'id': id,
      'key': API_KEY,
    };

    final url = Uri.https(
      _baseUrl, 
      '/youtube/v3/videos', 
      parameters
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if(response.statusCode == 200) {
      final data = json.decode(response.body);
      final item = data['items'][0];
      return Video.fromMap(item);
    } else {
      throw Exception('動画情報の取得に失敗しました');
    }
  }

  /// プレイリスト取得
  Future<List<Video>> fetchVideosFromPlaylistId(String playlistId) async {
    final parameters = {
      'part': 'snippet',
      'maxResults': '20',
      'playlistId': playlistId,
      'key': API_KEY,
    };

    final url = Uri.https(
      _baseUrl, 
      '/youtube/v3/playlistItems', 
      parameters
    );

    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    
    final response = await http.get(url, headers: headers);
    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List;
      return items.map((item) => Video.fromMap(item)).toList();
    } else {
      throw Exception('動画情報の取得に失敗しました');
    }
  }
}