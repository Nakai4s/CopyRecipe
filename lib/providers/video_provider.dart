import 'package:copy_recipe/services/api_service.dart';
import 'package:copy_recipe/utilities/text_extract_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/video_model.dart';

final videoProvider = NotifierProvider<VideoNotifier, List<Video>>(VideoNotifier.new);

class VideoNotifier extends Notifier<List<Video>> {
  late Box<Video> _box;

  RegExp videoRegex = RegExp(r'(?:v=|\/)([0-9A-Za-z_-]{11})');
  RegExp listRegex = RegExp(r'(?:list=)([a-zA-Z0-9_-]+)');

  @override
  List<Video> build() {
    _box = Hive.box<Video>('Videos');
    return _box.values.toList();
  }

  // 初期化：Hive Boxを開いてデータ読み込み
  // Future<void> loadFromStorage() async {
  //   _box = Hive.box<Video>('Videos');
  //   state = _box.values.toList();
  // }

  // 保存：全件保存（上書き）
  Future<void> saveToStorage() async {
    await _box.clear();
    state = _box.values.toList();
    // for (final v in state) {
    //   await _box.put(v.id, v);
    // }
  }

  /// URLからプレイリストIDを抽出
  String? extractId(String url, RegExp regex) {
    // URLが不正であれば
    if(!APIService.instance.isValidYoutubeUrl(url)){
      return null;
    }
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// URLから動画を抽出する
  Future<void> extractVideoFromUrl(String url) async {
    // URLが不正であれば例外をスロー
    if(!APIService.instance.isValidYoutubeUrl(url)){
      debugPrint('不正なURLです');
      throw Exception('不正なURLです');
    }

    // プレイリストIDがあればプレイリストとして処理
    final videoId = extractId(url, videoRegex);
    final playlistId = extractId(url, listRegex);

    List<Video> videos = [];

    // 動画IDのみ取得できた場合
    if(videoId != null && playlistId == null) {
      videos.add(await APIService.instance.fetchVideoFromId(videoId));
    }
    // プレイリストIDのみ取得できた場合
    else if(videoId == null && playlistId != null) {
      videos = await APIService.instance.fetchVideosFromPlaylistId(playlistId);    
    }
    // どちらも取得できなかった場合
    else {
      debugPrint('動画またはプレイリストを取得できなかった');
      throw Exception('動画またはプレイリストを取得できませんでした');
    }

    // 概要欄からレシピを抽出できるか確認する
    for (final video in videos) {
      // 既に存在する場合はスキップ
      if (TextExtractUtils.extractRecipe(video.description) == '') {
        debugPrint('概要欄からレシピを抽出できませんでした: ${video.title}');
        continue;
      }
      await _box.put(video.id, video);
    }

    state = _box.values.toList();
  }

  /// IDで動画を削除
  Future<void> deleteId(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }
}