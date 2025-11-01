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
      return Video.fromMap(data);
    } else {
      throw Exception('Failed to load video description');
    }
  }

  /// 概要欄を取得する
  Future<String> fetchVideoDescription(String videoId) async {
    final parameters = {
      'part': 'snippet',
      'id': videoId,
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
      return data['items'][0]['snippet']['description'];
    } else {
      throw Exception('Failed to load video description');
    }
  }
}