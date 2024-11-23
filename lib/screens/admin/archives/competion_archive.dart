import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/archives/images_archive_screen.dart';
import 'package:quranic_competition/screens/admin/archives/upload_archive.dart';
import 'package:quranic_competition/screens/admin/archives/video_archive_screen.dart';

class CompetionArchive extends StatefulWidget {
  final Competition competition;
  const CompetionArchive({super.key, required this.competition});

  @override
  State<CompetionArchive> createState() => _CompetionArchiveState();
}

class _CompetionArchiveState extends State<CompetionArchive> {
  @override
  Widget build(BuildContext context) {
    AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 60,
        title: Text(
          widget.competition.competitionVirsion.toString(),
        ),
        actions: [
          if (authProvider.user != null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadArchive(
                      competition: widget.competition,
                      competitionVirsion:
                          widget.competition.competitionVirsion.toString(),
                    ),
                  ),
                );
              },
              child: const Column(
                children: [
                  Icon(
                    Iconsax.add_circle,
                    color: AppColors.whiteColor,
                  ),
                  Text(
                    "أرشيف",
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the competition managment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagesArchiveScreen(
                      competition: widget.competition,
                    ),
                  ),
                );
              },
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/archive_image.png',
                      width: 70,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'أرشيف الصور',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the competition managment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoArchiveScreen(
                      competition: widget.competition,
                    ),
                  ),
                );
              },
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/archive_video.png',
                      width: 70,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'أرشيف الفيديو',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
