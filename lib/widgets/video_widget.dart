import 'dart:io';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String videoSource; // يمكن أن يكون رابط URL أو مسار ملف محلي

  const VideoWidget({super.key, required this.videoSource});

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();

    // تحديد ما إذا كان الفيديو من الإنترنت أو من الجهاز المحلي
    if (isNetworkSource(widget.videoSource)) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(widget.videoSource)
          ..initialize().then((_) {
            // وقف الفيديو فورًا بعد التهيئة
            setState(() {});
            flickManager.flickControlManager!.pause();
          }),
      );
    } else {
      flickManager = FlickManager(
        videoPlayerController:
            VideoPlayerController.file(File(widget.videoSource))
              ..initialize().then((_) {
                // وقف الفيديو فورًا بعد التهيئة
                setState(() {});
                flickManager.flickControlManager!.pause();
              },),
      );
    }
  }

  @override
  void dispose() {
    flickManager.dispose(); // تأكد من التخلص من الموارد عند إغلاق الودجت
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return flickManager.flickVideoManager!.isVideoInitialized
        ? Container(
            padding: const EdgeInsets.all(3.0),
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(
              bottom: 5.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2.0, 2.0),
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 2,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FlickVideoPlayer(
                flickManager: flickManager,
                flickVideoWithControls: const FlickVideoWithControls(
                  controls: FlickPortraitControls(),
                ),
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(3.0),
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(
              bottom: 5.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: AppColors.blackColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2.0, 2.0),
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 2,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ); // إظهار مؤشر التحميل إذا لم يكن الفيديو مهيئًا بعد
  }

  // دالة بسيطة لتحديد ما إذا كانت سلسلة النصوص عبارة عن رابط URL أو مسار ملف
  bool isNetworkSource(String videoSource) {
    return videoSource.startsWith('http') || videoSource.startsWith('https');
  }
}
