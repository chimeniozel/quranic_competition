import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class EditVideoScreen extends StatefulWidget {
  final VideoEntry videoEntry;
  final Competition competition;
  const EditVideoScreen(
      {super.key, required this.competition, required this.videoEntry});

  @override
  State<EditVideoScreen> createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen> {
  TextEditingController videoController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    videoController.text = widget.videoEntry.url!;
    titleController.text = widget.videoEntry.title!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('تعديل فيديو'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              InputWidget(
                  label: "عنوان فيديو يوتيوب",
                  controller: titleController,
                  hint: "عنوان فيديو يوتيوب"),
              const SizedBox(
                height: 10.0,
              ),
              InputWidget(
                label: "رابط فيديو يوتيوب",
                controller: videoController,
                hint: "رابط فيديو يوتيوب",
                // maxLines: 2,
                validator: (String? value) {
                  // Regular expression to validate YouTube video URL
                  const youtubeUrlPattern =
                      r'^(https?://)?(www\.)?(youtu\.be/|youtube\.com/(watch\?v=|embed/|v/))([a-zA-Z0-9_-]{11})([&?][\w=]*)?$';
                  final regExp = RegExp(youtubeUrlPattern);

                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان URL';
                  } else if (!regExp.hasMatch(value)) {
                    return 'الرجاء إدخال عنوان URL صالح لليوتيوب';
                  }

                  return null; // Valid YouTube URL
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          VideoEntry videoEntry = VideoEntry(
              title: titleController.text, url: videoController.text);
          CompetitionService.updateVideoURL(
                  context, widget.competition, videoEntry, widget.videoEntry)
              .whenComplete(
            () {
              Navigator.pop(context);
            },
          );
        },
        child: const Icon(Iconsax.video_add),
      ),
    );
  }
}
