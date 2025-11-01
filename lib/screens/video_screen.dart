import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final String id;

  VideoScreen({required this.id});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {

  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return _controller != null ? 
    YoutubePlayer(
      controller: _controller!,
      showVideoProgressIndicator: true,    
    )
    : Column(
      children: [
        Text('ここに動画が表示されます'),
      ],
    );
  }
}