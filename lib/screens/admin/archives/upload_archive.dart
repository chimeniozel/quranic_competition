import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path; // for file basename
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';
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

  final List<TextEditingController> _videoControllers = [];
  final List<TextEditingController> _titleControllers = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _addVideoUrlField() {
    setState(() {
      _videoControllers.add(TextEditingController());
      _titleControllers.add(TextEditingController());
    });
  }

  void _removeVideoUrlField(int index) {
    setState(() {
      _videoControllers[index].dispose();
      _videoControllers.removeAt(index);
      _titleControllers[index].dispose();
      _titleControllers.removeAt(index);
    });
  }

  void _submitUrls() async {
    setState(() {
      isLoading = true;
    });
    if (_selectedImages.isNotEmpty) {
      await _uploadImages(context, widget.competition);
    }
    if (_videoControllers.isNotEmpty) {
      if (!_formKey.currentState!.validate()) {
        // Validation failed
        setState(() {
          isLoading = false;
        });
        return;
      }
      final titleUrls =
          _titleControllers.map((controller) => controller.text).toList();
      final videoUrls =
          _videoControllers.map((controller) => controller.text).toList();
      List<VideoEntry> videos = [];
      for (var i = 0; i < _titleControllers.length; i++) {
        VideoEntry videoEntry = VideoEntry(
          title: titleUrls[i],
          url: videoUrls[i],
        );
        videos.add(videoEntry);
      }
      CompetitionService.updateVideosURL(context, widget.competition, videos)
          .whenComplete(() {
        setState(() {
          isLoading = false;
        });
      }).whenComplete(() {
        _videoControllers.clear();
        _titleControllers.clear();
        Navigator.pop(context);
      });
    }
    if (_selectedImages.isEmpty && _videoControllers.isEmpty) {
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
  }

  @override
  void dispose() {
    // التخلص من كل الـ Controllers عند إغلاق الشاشة
    for (var controller in _videoControllers) {
      controller.dispose();
    }

    for (var controller in _titleControllers) {
      controller.dispose();
    }
    for (var manager in _flickManagers) {
      manager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('إضافة أرشيف للمسابقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("إضافة صور"),
              const SizedBox(height: 10.0),
              // Display selected images
              if (_selectedImages.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
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

              const SizedBox(height: 20.0),
              const Text("إضافة فيديوهات"),
              const SizedBox(height: 10.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _videoControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                InputWidget(
                                    label: "عنوان فيديو يوتيوب",
                                    controller: _titleControllers[index],
                                    hint: "عنوان فيديو يوتيوب"),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                InputWidget(
                                  label: "رابط فيديو يوتيوب",
                                  controller: _videoControllers[index],
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
                          IconButton(
                            icon: const Icon(Iconsax.video_remove,
                                color: Colors.red),
                            onPressed: () => _removeVideoUrlField(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColors.grayLigthColor,
              ),
              onPressed: _selectImages,
              icon: const Icon(Iconsax.image4),
              label: const Text("اختر صور"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColors.grayLigthColor,
              ),
              onPressed: _addVideoUrlField,
              icon: const Icon(Iconsax.video),
              label: const Text("إضافة رابط"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: AppColors.grayLigthColor,
              ),
              onPressed: _submitUrls,
              child: const Text("حفظ الروابط"),
            ),
          ],
        ),
      ),
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: ElevatedButton(
      //     style: ElevatedButton.styleFrom(
      //       backgroundColor: AppColors.primaryColor,
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10.0),
      //       ),
      //       minimumSize: const Size(
      //         double.infinity,
      //         50.0,
      //       ),
      //     ),
      //     onPressed: () async {
      //       setState(() {
      //         isLoading = true;
      //       });
      //       if (_selectedImages.isNotEmpty) {
      //         await _uploadImages(context, widget.competition);
      //       }
      //       if (videoUrlController.text.isNotEmpty) {
      //         if (!_formKey.currentState!.validate()) {
      //           // Validation failed
      //           setState(() {
      //             isLoading = false;
      //           });
      //           return;
      //         }
      //         CompetitionService.updateVideosURL(
      //                 context, widget.competition, [videoUrlController.text])
      //             .whenComplete(() {
      //           setState(() {
      //             isLoading = false;
      //           });
      //         });
      //       }
      //       if (_selectedImages.isEmpty && videoUrlController.text.isEmpty) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //             content: Text('قم بتحميل ملفات'),
      //           ),
      //         );
      //         setState(() {
      //           isLoading = false;
      //         });
      //       }
      //       setState(() {
      //         isLoading = false;
      //       });
      //     },
      //     child: isLoading
      //         ? CircularProgressIndicator(
      //             value: _selectedImages.isNotEmpty
      //                 ? imagesProgress
      //                 : videosProgress, // Bind the progress value
      //             backgroundColor: AppColors.whiteColor,
      //             color: AppColors.greenColor,
      //           )
      //         : const Text(
      //             "حفظ",
      //             style: TextStyle(
      //               color: Colors.white,
      //             ),
      //           ),
      //   ),
      // ),
    );
  }
}
