import 'package:flutter/material.dart';
import 'package:fun/AppColors.dart';
import 'package:fun/VideoListItem.dart';
import 'package:video_player/video_player.dart';

class Videos extends StatefulWidget {
  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(),
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text(
          'Videos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontFamily: "Times New Roman",
          ),
        ),
      ),
      body: buildBody(),
    );
  }

  buildBody()
  {
    return ListView(
      children: <Widget>[
        addVideo('videos/intro.mp4', 'A Video Title'),
        addVideo('videos/intro.mp4', 'A Video Title'),
        addVideo('videos/intro.mp4', 'A Video Title'),
      ],
    );
  }

  addVideo(String name, String title)
  {
    return Container(
      margin: EdgeInsets.all(8.0),
      color: AppColors.containerColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          VideoListItem(
            videoPlayerController: VideoPlayerController.asset(name),
            looping: false,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textColor(),
                fontSize: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
