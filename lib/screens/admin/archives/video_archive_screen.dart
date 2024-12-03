import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/archives/edit_video_screen.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoArchiveScreen extends StatefulWidget {
  final Competition competition;
  const VideoArchiveScreen({super.key, required this.competition});

  @override
  _VideoArchiveScreenState createState() => _VideoArchiveScreenState();
}

class _VideoArchiveScreenState extends State<VideoArchiveScreen> {
  final List<VideoEntry> _videos = [];
  int? _lastVideo = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  static const int _limit = 15;

  @override
  void initState() {
    super.initState();
    _loadVideos(); // Initial load
  }

  Future<void> _loadVideos() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<VideoEntry> newVideos =
          await CompetitionService.getVideosArchivesStream(
        widget.competition.competitionId!,
        limit: _limit,
        lastVideo: _lastVideo,
      );

      if (newVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(newVideos);
          _lastVideo = _videos.indexOf(_videos.last);
        });
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (error) {
      print("Error loading videos: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text("روابط فيديوهات ${widget.competition.competitionVirsion}"),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadVideos();
            return true;
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _videos.isEmpty && !_isLoading
              ? const Center(
                  child: Text('لا تتوفر أرشيفات الفيديو'),
                )
              : ListView.builder(
                  itemCount: _videos.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _videos.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    VideoEntry video = _videos[index];
                    return GestureDetector(
                      onTap: () {
                        _launchURL(video.url!);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppColors.whiteColor,
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0.0, 2.0),
                              blurRadius: 10.0,
                              color: Colors.black12,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20.0,
                              backgroundColor: Colors.blue,
                              child: Image.asset(
                                  "assets/images/logos/youtube.png"),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.title!,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (authProvider.currentAdmin == null)
                              IconButton(
                                onPressed: () {
                                  _launchURL(video.url!);
                                },
                                icon: const Icon(Iconsax.arrow_left_2),
                              ),
                            if (authProvider.currentAdmin != null)
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditVideoScreen(
                                            competition: widget.competition,
                                            videoEntry: video,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Iconsax.edit,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("تأكيد الحذف"),
                                            content: const Text(
                                                "هل أنت متأكد أنك تريد حذف هذا الفيديو؟"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text("إلغاء"),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'competitions')
                                                      .doc(widget.competition
                                                          .competitionId)
                                                      .update({
                                                    'archiveEntry.videosURL':
                                                        FieldValue.arrayRemove(
                                                            [video.toMap()]),
                                                  });
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  "حذف",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Iconsax.video_remove,
                                      color: AppColors.pinkColor,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
