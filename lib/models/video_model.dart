class Video{
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
  });

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      id: map['id'] ?? '',
      title: map['snippet']['title'],
      thumbnailUrl: map['snippet']['thumbnails']['high']['url'],
      channelTitle: map['snippet']['channelTitle'] ?? map['snippet']['customUrl'] ?? '',
    );
  }
}