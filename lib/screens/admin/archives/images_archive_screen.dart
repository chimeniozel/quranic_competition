import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/screens/admin/archives/review_competion.dart';
import 'package:quranic_competition/services/competion_service.dart';

class ImagesArchiveScreen extends StatefulWidget {
  final Competition competition;
  const ImagesArchiveScreen({super.key, required this.competition});

  @override
  State<ImagesArchiveScreen> createState() => _ImagesArchiveScreenState();
}

class _ImagesArchiveScreenState extends State<ImagesArchiveScreen> {
  List<String> _images = [];
  bool _isLoading = false;
  bool _hasMore = true; // Track if more images are available
  int lastImage = 0;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> newImages =
          await CompetitionService.getPaginatedImagesArchives(
        widget.competition.competitionId.toString(),
        limit: 18,
        lastImage: lastImage,
      );

      setState(() {
        _images.addAll(newImages);
        lastImage = _images.indexOf(_images.last);
        _isLoading = false;

        if (newImages.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('صور ${widget.competition.competitionVirsion}'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (!_isLoading &&
              _hasMore &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadImages();
            return true;
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _images.isEmpty && !_isLoading
              ? const Center(child: Text('لا تتوفر أرشيفات الصور'))
              : GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _images.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _images.length) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var archive = _images[index];
                    return GestureDetector(
                      onTap: () {
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
                            archive,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                  child: Text('Error loading image'));
                            },
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
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
