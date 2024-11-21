import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoArchiveScreen extends StatefulWidget {
  final Competition competition;
  const VideoArchiveScreen({super.key, required this.competition});
  @override
  VideoArchiveScreenState createState() => VideoArchiveScreenState();
}

class VideoArchiveScreenState extends State<VideoArchiveScreen> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication, // Ensures it opens in the Facebook app if available
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text("روابط الفيديوهات"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: FutureBuilder<List<VideoEntry>>(
              future: CompetitionService.getVideosArchives(
                  widget.competition.competitionId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  ); // Show error if any
                } else if (!snapshot.hasData ||
                    (snapshot.data as List).isEmpty) {
                  return const Center(
                    child: Text('لا تتوفر أرشيفات الصور'),
                  ); // Handle empty data case
                }

                List<VideoEntry>? videoEntry = snapshot.data;

                return ListView.builder(
                  itemCount: videoEntry!.length,
                  itemBuilder: (context, index) {
                    VideoEntry video = videoEntry[index];
                    return GestureDetector(
                      onTap: () {
                        _launchURL(video.url!);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          8.0,
                        ),
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
                                mainAxisAlignment: MainAxisAlignment.start,
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
                            IconButton(
                                onPressed: () {
                                  _launchURL(video.url!);
                                },
                                icon: const Icon(Iconsax.arrow_left_2))
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
        ));
  }
}