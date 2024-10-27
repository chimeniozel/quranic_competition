import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/screens/admin/competition_management/review_competion.dart';
import 'package:quranic_competition/screens/admin/competition_management/upload_archive.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/video_widget.dart';

class CompetionArchive extends StatefulWidget {
  final Competition competition;
  const CompetionArchive({super.key, required this.competition});

  @override
  State<CompetionArchive> createState() => _CompetionArchiveState();
}

class _CompetionArchiveState extends State<CompetionArchive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          widget.competition.competitionVirsion.toString(),
        ),
        actions: [
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
                Icon(Iconsax.add_circle),
                Text(
                  "أرشيف",
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("أرشيف الصور"),
              const SizedBox(
                height: 10.0,
              ),
              StreamBuilder(
                stream: CompetitionService.getImagesArchives(
                    widget.competition.competitionId.toString()),
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

                  List<String>? archives =
                      snapshot.data; // Ensure correct type for your archives

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: archives!.length,
                    itemBuilder: (context, index) {
                      var archive = archives[
                          index]; // Assuming archive contains image paths or URLs
                      return GestureDetector(
                        onTap: () {
                          // Navigator to Image View
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewCompetion(
                                itemUrl: archive,
                                competitionId:
                                    widget.competition.competitionId.toString(),
                                isImage: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(2.0, 2.0),
                                color: Colors.black.withOpacity(.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              archive, // Replace with the correct field for the image URL
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child: Text('Error loading image'));
                              },
                              frameBuilder: (context, child, frame,
                                  wasSynchronouslyLoaded) {
                                if (wasSynchronouslyLoaded) {
                                  return child; // If the image is loaded instantly, display the image.
                                }
                                return frame == null
                                    ? const SizedBox(
                                        height: 70,
                                        width: 70,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors
                                                .primaryColor, // Customize color as needed
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      ) // Display a CircularProgressIndicator while the image is loading.
                                    : child; // Once the image is loaded, display the image.
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text("أرشيف الفيديو"),
              const SizedBox(
                height: 10.0,
              ),
              StreamBuilder<List<String>>(
                stream: CompetitionService.getVideosArchives(
                    widget.competition.competitionId.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    ); // Handle error
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا تتوفر أرشيفات الفيديو',
                      ),
                    ); // Handle empty case
                  }

                  List<String> archives = snapshot.data!;

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: archives.length,
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      var videoUrl = archives[index];
                      // Create a stateful widget to manage the video controller and its state
                      return Column(
                        children: [
                          VideoWidget(videoSource: videoUrl),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.pinkColor,
                              minimumSize: const Size(double.infinity, 45.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("تأكيد الحذف"),
                                    content: const Text(
                                        "هل أنت متأكد أنك تريد حذف هذا العنصر؟"),
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
                                          FirebaseFirestore.instance
                                              .collection("competitions")
                                              .doc(widget
                                                  .competition.competitionId)
                                              .update({
                                            "archiveEntry.videosURL":
                                                FieldValue.arrayRemove(
                                              [videoUrl],
                                            ),
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "حذف",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text(
                              "حذف",
                              style: TextStyle(
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
