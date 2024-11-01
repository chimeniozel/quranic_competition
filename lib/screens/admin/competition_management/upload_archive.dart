import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path; // for file basename
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/video_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';

class UploadArchive extends StatefulWidget {
  final Competition competition;
  final String competitionVirsion;
  const UploadArchive(
      {super.key, required this.competition, required this.competitionVirsion});

  @override
  UploadArchiveState createState() => UploadArchiveState();
}

class UploadArchiveState extends State<UploadArchive> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<XFile> _selectedVideos = [];
  final List<FlickManager> _flickManagers = [];
  bool isLoading = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  double? imagesProgress = 0.0;
  double? videosProgress = 0.0;

  // Select multiple images
  Future<void> _selectImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    setState(() {
      _selectedImages.addAll(selectedImages);
    });
  }

  // Select multiple videos
  Future<void> _selectVideos() async {
    final XFile? selectedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (selectedVideo != null) {
      setState(() {
        _selectedVideos.add(selectedVideo);

        // Create a FlickManager for each video
        FlickManager flickManager = FlickManager(
          videoPlayerController:
              VideoPlayerController.file(File(selectedVideo.path))
                ..initialize().then((_) {
                  setState(() {}); // Refresh UI when the video is initialized
                }),
        );
        _flickManagers.add(flickManager);
      });
    }
  }

  Future<void> _uploadImages(
      BuildContext context, Competition competition) async {
    List<String> imageUrls = []; // List to store image URLs

    for (XFile image in _selectedImages) {
      try {
        String fileName = path.basename(image.path); // Use path.basename
        File file = File(image.path);

        // Upload to Firebase Storage with progress tracking
        UploadTask uploadTask = _storage
            .ref('${competition.competitionVirsion}/images/$fileName')
            .putFile(file);

        // Listen to the upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            imagesProgress = progress;
          });
          // int percentage = (progress * 100).round();
        });

        // Wait until the upload completes
        TaskSnapshot completedTask = await uploadTask;

        // Get the download URL
        String downloadURL = await completedTask.ref.getDownloadURL();
        imageUrls.add(downloadURL); // Add the URL to the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
          ),
        );
      }
    }

    competition.setArchiveEntry = ArchiveEntry(imagesURL: imageUrls);
    CompetitionService.updateImagesURL(context, competition).whenComplete(() {
      _selectedImages.clear();
    });

    // Show a success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحميل الصور بنجاح!'),
        backgroundColor: AppColors.greenColor,
      ),
    );
  }

// Upload videos to Firebase Storage and get their URLs
  Future<void> _uploadVideos(
      BuildContext context, Competition competition) async {
    List<String> videoUrls = []; // List to store video URLs

    for (XFile video in _selectedVideos) {
      try {
        String fileName = path.basename(video.path); // Use path.basename
        File file = File(video.path);

        // Upload to Firebase Storage with progress tracking
        UploadTask uploadTask = _storage
            .ref('${competition.competitionVirsion}/videos/$fileName')
            .putFile(file);

        // Listen to the upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          setState(() {
            videosProgress = progress; // Update the video upload progress
          });
        });

        // Wait until the upload completes
        TaskSnapshot completedTask = await uploadTask;

        // Get the download URL
        String downloadURL = await completedTask.ref.getDownloadURL();
        videoUrls.add(downloadURL); // Add the URL to the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    }

    competition.setArchiveEntry = ArchiveEntry(videosURL: videoUrls);
    CompetitionService.updateVideosURL(context, competition).whenComplete(() {
      _selectedVideos.clear();
    });

    // Show a success Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحميل الفيديو بنجاح!'),
        backgroundColor: AppColors.greenColor,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose FlickManagers
    for (var manager in _flickManagers) {
      manager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة أرشيف للمسابقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("إضافة صور"),
              const SizedBox(height: 10.0),
              // Display selected images
              if (_selectedImages.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
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
                          child: Image.file(
                            File(_selectedImages[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_selectedImages.isEmpty)
                const Center(
                  child: Text("لم يتم اختيار صور بعد"),
                ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _selectImages,
                child: const Text('اختر صور'),
              ),
              const SizedBox(height: 20.0),
              const Text("إضافة فيديوهات"),
              const SizedBox(height: 10.0),
              // Display selected videos with FlickVideoPlayer
              if (_selectedVideos.isNotEmpty)
                Column(
                  children: List.generate(
                    _flickManagers.length,
                    (index) {
                      // FlickManager flickManager = _flickManagers[index];
                      return VideoWidget(
                          videoSource: _selectedVideos[index].path);
                    },
                  ),
                ),
              ElevatedButton(
                onPressed: _selectVideos,
                child: const Text('اختر فيديوهات'),
              ),
              if (_selectedVideos.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(
                    child: Text("لم يتم اختيار فيديوهات بعد"),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            minimumSize: const Size(
              double.infinity,
              50.0,
            ),
          ),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            if (_selectedImages.isNotEmpty) {
              await _uploadImages(context, widget.competition);
            }
            if (_selectedVideos.isNotEmpty) {
              await _uploadVideos(context, widget.competition);
            }
            if (_selectedImages.isEmpty && _selectedVideos.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('قم بتحميل ملفات'),
                ),
              );
              setState(() {
                isLoading = false;
              });
            }
            setState(() {
              isLoading = false;
            });
          },
          child: isLoading
              ? CircularProgressIndicator(
                  value: _selectedImages.isNotEmpty
                      ? imagesProgress
                      : videosProgress, // Bind the progress value
                  backgroundColor: AppColors.whiteColor,
                  color: AppColors.greenColor,
                )
              : const Text(
                  "حفظ",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
