import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/tajweed_video_model.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class EditTajweedVideoScreen extends StatefulWidget {
  final TajweedVideoModel tajweedVideoModel;
  const EditTajweedVideoScreen({super.key, required this.tajweedVideoModel});

  @override
  State<EditTajweedVideoScreen> createState() => _EditTajweedVideoScreenState();
}

class _EditTajweedVideoScreenState extends State<EditTajweedVideoScreen> {
  TextEditingController videoController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    videoController.text = widget.tajweedVideoModel.url!;
    titleController.text = widget.tajweedVideoModel.title!;
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
        onPressed: () async {
          widget.tajweedVideoModel.title = titleController.text;
          widget.tajweedVideoModel.url = videoController.text;
          await FirebaseFirestore.instance
              .collection("ahkam_tajweed_videos")
              .doc(widget.tajweedVideoModel.id)
              .update({
            "title": titleController.text,
            "url": videoController.text,
          }).whenComplete(
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
