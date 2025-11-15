import 'package:copy_recipe/services/api_service.dart';
import 'package:copy_recipe/utilities/text_extract_utils.dart';
import 'package:flutter/material.dart';
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
  // Future<void> saveToStorage() async {
  //   await _box.clear();
  //   state = _box.values.toList();
  //   // for (final v in state) {
  //   //   await _box.put(v.id, v);
  //   // }
  // }

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
  Future<void> extractVideoFromUrl(String url, BuildContext context) async {
    try {
      // YoutubeのURLでなければ処理を抜ける
      if(!APIService.instance.isValidYoutubeUrl(url)){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('不正なURLです')),
        );
        return;
      }

      // プレイリストIDがあればプレイリストとして処理
      final videoId = extractId(url, videoRegex);
      final playlistId = extractId(url, listRegex);

      // 動画を一時的に格納するリスト
      List<Video> videos = [];
      // レシピを抽出できた動画を一時的に格納するリスト
      List<Video> recipeVideos = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('動画を取得できませんでした')),
        );
        return;
      }

      // レシピを抽出できた動画リストを取得
      recipeVideos = videos.where((v) => TextExtractUtils.extractRecipe(v.description) != '').toList();
      if(recipeVideos.isEmpty) {
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('レシピを抽出できる動画がありませんでした')),
          );
        }
        return;
      }
      else {
        // Hiveに保存
        for (final video in recipeVideos) {
          await _box.put(video.id, video);
        }
        // stateを更新
        state = _box.values.toList();

        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${videos.length}件中、${recipeVideos.length}件のレシピを追加しました')),
          );
        }
      }
    } catch (e) {
      debugPrint('エラーが発生しました: ${e.toString()}');
    }
  }

  /// IDで動画を削除
  Future<void> deleteId(String id) async {
    // 1. 即座に state を更新 → UI が Dismissible を削除
    state = state.where((video) => video.id != id).toList();
    // 2. 非同期処理（Hive など）を後で実行
    await _box.delete(id);
  }
}