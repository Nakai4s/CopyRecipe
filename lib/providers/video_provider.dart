import 'package:copy_recipe/services/api_service.dart';
import 'package:copy_recipe/utilities/text_extract_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/video_model.dart';

final videoProvider = NotifierProvider<VideoNotifier, List<Video>>(VideoNotifier.new);

class VideoNotifier extends Notifier<List<Video>> {
  late Box<Video> _box;

  static final _videoRegex = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
  static final _listRegex = RegExp(r'(?:list=)([a-zA-Z0-9_-]+)');

  @override
  List<Video> build() {
    _box = Hive.box<Video>('Videos');
    return _box.values.toList();
  }

  String? _extractId(String url, RegExp regex) {
    return regex.firstMatch(url)?.group(1);
  }

  /// URLから動画を抽出する
  Future<void> extractVideoFromUrl(String url) async {
    if (!APIService.instance.isValidYoutubeUrl(url)) {
      throw Exception('不正なURLです');
    }

    final videoId = _extractId(url, _videoRegex);
    final playlistId = _extractId(url, _listRegex);

    final List<Video> fetchedVideos;
    if (videoId != null) {
      fetchedVideos = [await APIService.instance.fetchVideoFromId(videoId)];
    } else if (playlistId != null) {
      fetchedVideos = await APIService.instance.fetchVideosFromPlaylistId(playlistId);
    } else {
      throw Exception('動画を取得できませんでした');
    }

    final hasRecipe = fetchedVideos.any(
      (v) => TextExtractUtils.extractRecipe(v.description) != '',
    );
    if (!hasRecipe) {
      throw Exception('レシピを抽出できる動画がありませんでした');
    }

    for (final video in fetchedVideos) {
      await _box.put(video.id, video);
    }
    state = _box.values.toList();
  }

  /// IDで動画を削除
  Future<void> deleteId(String id) async {
    state = state.where((video) => video.id != id).toList();
    await _box.delete(id);
  }
}