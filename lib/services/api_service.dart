import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:copy_recipe/models/channel_model.dart';
import 'package:copy_recipe/models/video_model.dart';
import 'package:copy_recipe/utilities/keys.dart';

class APIService {

  APIService._instantiate();

  static final APIService instance = APIService._instantiate();
  
  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<Channel> fetchChannel({required String handleId}) async {
    Map<String, String> parameters = {
      'part': 'snippet, contentDetails, statistics',
      'forHandle': handleId,
      'key': API_KEY,
    };
    Uri uri = Uri.https(
      _baseUrl, 
      '/youtube/v3/channels', 
      parameters
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);

      // Fetch first batch of videos from uploads playlist
      channel.videos = await fetchVideosFromPlaylist(
        playlistId: channel.uploadPlaylistId,
      );      
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<List<Video>> fetchVideosFromPlaylist({required String playlistId}) async {
    final parameters = {
      'part': 'snippet',
      'forHandle': '@kanayukiex',
      'playlistId': playlistId,
      'maxResults': '8',
      'pageToken': _nextPageToken,
      'key': API_KEY,
    };

    final uri = Uri.https(
      _baseUrl, 
      '/youtube/v3/channels', 
      parameters
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Get Playlist Videos
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      _nextPageToken = data['nextPageToken'] ?? '';
      List<dynamic> videosJson = data['items'];

      // Fetch first eight videos from uploads playlist
      List<Video> videos = [];
      videosJson.forEach(
        (json) => videos.add(
          Video.fromMap(json),
        ),
      );
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}