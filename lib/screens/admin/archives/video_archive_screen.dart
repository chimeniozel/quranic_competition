import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/admin/archives/edit_video_screen.dart';
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
    final AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);
    CompetitionProvider provider =
        Provider.of<CompetitionProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
              "روابط فيديوهات ${provider.competition!.competitionVirsion}"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: StreamBuilder<List<VideoEntry>>(
              stream: CompetitionService.getVideosArchivesStream(
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
                    child: Text('لا تتوفر أرشيفات الفيديو'),
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
                        margin: const EdgeInsets.symmetric(
                          vertical: 2.0,
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
                            if (authProvider.currentAdmin == null)
                              IconButton(
                                onPressed: () {
                                  _launchURL(video.url!);
                                },
                                icon: const Icon(
                                  Iconsax.edit,
                                ),
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
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
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
                                                          .competitionId) // Reference to the specific competition document
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
                );
              }),
        ));
  }
}
