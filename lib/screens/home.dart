import 'package:copy_recipe/models/channel_model.dart';
import 'package:copy_recipe/models/video_model.dart';
import 'package:flutter/material.dart';
import 'package:copy_recipe/services/api_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {

  Channel? _channel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    Channel channel = await APIService.instance.
      fetchChannel(handleId: '@kanayukiex', // Example Channel ID
    );
    setState(() {
      _channel = channel;
    });
  }

  _loadMoreVideos() async {
    _isLoading = true;
      List<Video> moreVideos = await APIService.instance.
        fetchVideosFromPlaylist(
          playlistId: _channel!.uploadPlaylistId,
      );
      List<Video> allVideos = _channel!.videos..addAll(moreVideos);
      setState(() {
        _channel!.videos = allVideos;
      });
      _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: _channel != null 
      ? NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollDetails) {
          if(!_isLoading && 
            _channel!.videos.length != int.parse(_channel!.videoCount) &&
            scrollDetails.metrics.pixels == scrollDetails.metrics.maxScrollExtent) {
              _loadMoreVideos();  
            }
            return false;
        },
        child: ListView.builder(
          itemCount: 1 + _channel!.videos.length,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return _buildProfileInfo();
            }
            Video video = _channel!.videos[index - 1];
            return _buildVideo(video);
          }
        ),
      ) 
      : const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.red,
          ),
        ),
      ),
    );
  }

  _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(_channel!.profilePictureUrl),
            radius: 35.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _channel!.title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_channel!.subscriberCount} subscribers',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  _buildVideo(Video video) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      padding: const EdgeInsets.all(10.0),
      height: 140.0,
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Image(
            width: 150.0,
            image: NetworkImage(video.thumbnailUrl),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Text(
              video.title,
              style: const TextStyle(
                color: Colors.black12,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
            )
          ),
        ],
      ),
    );
  }
}