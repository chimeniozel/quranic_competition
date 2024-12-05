import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/tajweed_video_model.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class AddTajweedVideoScreen extends StatefulWidget {
  const AddTajweedVideoScreen({super.key});

  @override
  State<AddTajweedVideoScreen> createState() => _AddTajweedVideoScreenState();
}

class _AddTajweedVideoScreenState extends State<AddTajweedVideoScreen> {
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

  @override
  void initState() {
    _addVideoUrlField();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('أضف رابط فيديو'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _videoControllers.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 5.0,
                      ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: _addVideoUrlField,
        tooltip: "إضافة رابط",
        child: const Icon(Iconsax.add),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          // save video entry
          if (_videoControllers.isNotEmpty) {
            if (!_formKey.currentState!.validate()) {
              // Validation failed
              return;
            }
            final titleUrls =
                _titleControllers.map((controller) => controller.text).toList();
            final videoUrls =
                _videoControllers.map((controller) => controller.text).toList();
            List<TajweedVideoModel> videos = [];
            for (var i = 0; i < _titleControllers.length; i++) {
              TajweedVideoModel tajweedVideoModel = TajweedVideoModel(
                title: titleUrls[i],
                url: videoUrls[i],
                createdAt: DateTime.now(),
              );
              videos.add(tajweedVideoModel);
            }
            for (var element in videos) {
              FirebaseFirestore.instance
                  .collection("ahkam_tajweed_videos")
                  .add(element.toMap())
                  .then((value) async {
                FirebaseFirestore.instance
                    .collection("ahkam_tajweed_videos")
                    .doc(value.id)
                    .update({
                  "id": value.id,
                });
              });
            }
            final failureSnackBar = SnackBar(
              content: const Text("تم إضافة الفيديو بنجاح"),
              action: SnackBarAction(
                label: 'تراجع',
                onPressed: () {},
              ),
              backgroundColor: AppColors.greenColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
            _videoControllers.clear();
            _titleControllers.clear();
            Navigator.pop(context);
          }
        },
        child: Container(
          margin: const EdgeInsets.all(
            8.0,
          ),
          padding: const EdgeInsets.all(
            8.0,
          ),
          height: 56.0,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          child: const Center(
            child: Text(
              'حفظ',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
