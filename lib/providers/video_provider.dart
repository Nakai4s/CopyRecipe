import 'package:copy_recipe/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/video_model.dart';

final videoProvider = NotifierProvider<VideoNotifier, List<Video>>(VideoNotifier.new);

class VideoNotifier extends Notifier<List<Video>> {
  final _uuid = Uuid();
  late Box<Video> _box;

  @override
  List<Video> build() {
    _box = Hive.box<Video>('Videos');
    return _box.values.toList();
  }

  // 初期化：Hive Boxを開いてデータ読み込み
  Future<void> loadFromStorage() async {
    _box = Hive.box<Video>('Videos');
    state = _box.values.toList();
  }

  // 保存：全件保存（上書き）
  Future<void> saveToStorage() async {
    await _box.clear();
    for (final v in state) {
      await _box.put(v.id, v);
    }
  }

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
    final id = _uuid.v4();
    final videoId = extractVideoId(url);
    Video v = await APIService.instance.fetchVideoFromId(videoId);
    await _box.put(v.id, v);
    state = _box.values.toList();
    return v;
  }

  // ウィッシュリストを追加
  // Future<void> addVideo(String url) async {
  //   final id = _uuid.v4();
  //   final wish = Video(id: id, title: title, deadline: deadline, tasks: []);
  //   await _box.put(id, wish); // id をキーとして保存
  //   state = _box.values.toList();
  // }

  // Future<void> deleteVideoById(String id) async {
  //   await _box.delete(id);
  //   state = _box.values.toList();
  // }

  // Future<void> updateVideoById(String id, {String? title, DateTime? deadline}) async {
  //   final wish = _box.get(id);
  //   if (wish == null) return;
  //   if (title != null) wish.title = title;
  //   if (deadline != null) wish.deadline = deadline;
  //   await wish.save(); // HiveObject の save()
  //   state = _box.values.toList();
  // }

  // Future<void> addTaskToVideo(String wishId, String taskTitle) async {
  //   final wish = _box.get(wishId);
  //   if (wish == null) return;
  //   final task = Task(id: _uuid.v4(), title: taskTitle);
  //   wish.tasks = [...wish.tasks, task];
  //   await wish.save();
  //   state = _box.values.toList();
  // }

  // Future<void> toggleTaskComplete(String wishId, String taskId) async {
  //   final wish = _box.get(wishId);
  //   if (wish == null) return;
  //   final updated = wish.tasks.map((t) {
  //     if (t.id == taskId) return t.copyWith(isCompleted: !t.isCompleted);
  //     return t;
  //   }).toList();
  //   wish.tasks = updated;
  //   await wish.save();
  //   state = _box.values.toList();
  // }

  // Future<void> removeTask(String wishId, String taskId) async {
  //   final wish = _box.get(wishId);
  //   if (wish == null) return;
  //   wish.tasks = wish.tasks.where((t) => t.id != taskId).toList();
  //   await wish.save();
  //   state = _box.values.toList();
  // }
}