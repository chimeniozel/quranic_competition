import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CompetitionArchiveVideos extends StatefulWidget {
  const CompetitionArchiveVideos({super.key});

  @override
  State<CompetitionArchiveVideos> createState() =>
      _CompetitionArchiveVideosState();
}

class _CompetitionArchiveVideosState extends State<CompetitionArchiveVideos> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    try {
      final videoID =
          YoutubePlayer.convertUrlToId("https://youtu.be/Tp3F5uKxRAs");
      if (videoID == null) throw Exception("Invalid video URL");

      _controller = YoutubePlayerController(
        initialVideoId: videoID,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    } catch (e) {
      print("Error initializing YouTube Player: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Archive Videos"),
      ),
      body: _controller != null
          ? YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
            )
          : const Center(
              child: Text("Failed to load video"),
            ),
    );
  }
}
