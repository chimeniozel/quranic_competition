import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';

class UploadArchive extends StatefulWidget {
  final Competition competition;
  final String competitionVirsion;
  const UploadArchive(
      {super.key, required this.competition, required this.competitionVirsion});

  @override
  _UploadArchiveState createState() => _UploadArchiveState();
}

class _UploadArchiveState extends State<UploadArchive> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  List<XFile> _selectedVideos = [];
  List<FlickManager> _flickManagers = [];

  // Select multiple images
  Future<void> _selectImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();
    if (selectedImages != null) {
      setState(() {
        _selectedImages.addAll(selectedImages);
      });
    }
  }

  // Select multiple videos (manually call it multiple times for each selection)
  Future<void> _selectVideos() async {
    final XFile? selectedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);
    if (selectedVideo != null) {
      setState(() {
        _selectedVideos.add(selectedVideo);

        // Create a FlickManager for each video
        FlickManager flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.file(
              File(selectedVideo.path))
            ..initialize().then((_) {
              setState(() {}); // Refresh the UI when the video is initialized
            }),
        );
        _flickManagers.add(flickManager);
      });
    }
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
      appBar: AppBar(title: const Text('أرشيف المسابقة')),
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
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: AppColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(2.0, 2.0),
                        color: AppColors.blackColor.withOpacity(.1),
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
                          color: AppColors.whiteColor,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(2.0, 2.0),
                              color: AppColors.blackColor.withOpacity(.1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) {
                                return child;
                              }
                              return frame == null
                                  ? const SizedBox(
                                      height: 70,
                                      width: 70,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryColor,
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                    )
                                  : child;
                            },
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
                  children: List.generate(_flickManagers.length, (index) {
                    FlickManager flickManager = _flickManagers[index];
                    return flickManager.flickVideoManager!.isVideoInitialized
                        ? Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: AppColors.whiteColor,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(2.0, 2.0),
                                      color:
                                          AppColors.blackColor.withOpacity(.1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                width: double.infinity,
                                child: FlickVideoPlayer(
                                  wakelockEnabled: true,
                                  wakelockEnabledFullscreen: true,
                                  flickManager: flickManager,
                                  flickVideoWithControls:
                                      const FlickVideoWithControls(
                                    controls: FlickPortraitControls(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          )
                        : const SizedBox.shrink();
                  }),
                ),
              ElevatedButton(
                onPressed: _selectVideos,
                child: const Text('اختر فيديوهات'),
              ),
              if (_selectedVideos.isEmpty)
                const Center(
                  child: Text("لم يتم اختيار فيديوهات بعد"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
