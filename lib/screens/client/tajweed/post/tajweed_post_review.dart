import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/tajweed_post_model.dart';

class TajweedPostReview extends StatefulWidget {
  final TajweedPostModel model;
  const TajweedPostReview({super.key, required this.model});

  @override
  State<TajweedPostReview> createState() => _TajweedPostReviewState();
}

class _TajweedPostReviewState extends State<TajweedPostReview> {
  @override
  Widget build(BuildContext context) {
    final TajweedPostModel model = widget.model;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(model.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Text(
                model.content,
                style: const TextStyle(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    Utils.arDateFormat(model.createdAt),
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
