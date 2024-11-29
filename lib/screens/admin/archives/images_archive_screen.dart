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
  List<String>? _cachedImages; // Cache to store loaded images
  bool _isLoading = true; // Track loading state
  String? _error; // To store error message if any

  @override
  void initState() {
    super.initState();
    _loadImages(); // Load images when the widget initializes
  }

  Future<void> _loadImages() async {
    try {
      final images = await CompetitionService.getImagesArchives(
        widget.competition.competitionId.toString(),
      );
      setState(() {
        _cachedImages = images;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text('صور ${widget.competition.competitionVirsion}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Text('Error: $_error'),
                  )
                : (_cachedImages == null || _cachedImages!.isEmpty)
                    ? const Center(
                        child: Text('لا تتوفر أرشيفات الصور'),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _cachedImages!.length,
                        itemBuilder: (context, index) {
                          var archive = _cachedImages![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewCompetion(
                                    itemUrl: archive,
                                    competitionId: widget
                                        .competition.competitionId
                                        .toString(),
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
    );
  }
}
