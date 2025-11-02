import 'package:hive/hive.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class Video extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String thumbnailUrl;
  @HiveField(3)
  final String channelTitle;
  @HiveField(4)
  final String description;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.description,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] ?? '',
      title: map['snippet']['title'],
      thumbnailUrl: map['snippet']['thumbnails']['high']['url'],
      channelTitle: map['snippet']['channelTitle'],
      description: map['snippet']['description'],
    );
  }
}