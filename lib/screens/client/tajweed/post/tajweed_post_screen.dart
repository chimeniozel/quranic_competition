import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/tajweed_post_model.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/client/tajweed/post/add_tajweed_post_screen.dart';
import 'package:quranic_competition/screens/client/tajweed/post/tajweed_post_review.dart';
import 'package:quranic_competition/services/competion_service.dart';

class TajweedPostScreen extends StatefulWidget {
  const TajweedPostScreen({super.key});

  @override
  State<TajweedPostScreen> createState() => _TajweedPostScreenState();
}

class _TajweedPostScreenState extends State<TajweedPostScreen> {
  @override
  Widget build(BuildContext context) {
    final AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('المناشير التجويدية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: StreamBuilder<List<TajweedPostModel>>(
          stream: CompetitionService.getTajweedPost(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              ); // Show loading indicator while waiting
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              ); // Show error if any
            } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return const Center(
                child: Text('لا تتوفر مناشير تجويدية'),
              ); // Handle empty data case
            }

            List<TajweedPostModel>? videoEntry = snapshot.data;

            return ListView.builder(
              itemCount: videoEntry!.length,
              itemBuilder: (context, index) {
                TajweedPostModel model = videoEntry[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the TajweedPostReview
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TajweedPostReview(
                          model: model,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                      8.0,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 2.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AppColors.whiteColor,
                      boxShadow: const [
                        BoxShadow(
                          offset: Offset(0.0, 2.0),
                          blurRadius: 10.0,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20.0,
                          backgroundColor: AppColors.grayLigthColor,
                          child: Image.asset("assets/images/logos/logo.png"),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                model.title,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                model.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (authProvider.currentAdmin == null)
                          IconButton(
                            onPressed: () {
                              // _launchURL(video.url!);
                            },
                            icon: const Icon(
                              Iconsax.arrow_left_2,
                            ),
                          ),
                        if (authProvider.currentAdmin != null)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddTajweedPostScreen(
                                        model: model,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Iconsax.edit,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("تأكيد الحذف"),
                                        content: const Text(
                                            "هل أنت متأكد أنك تريد حذف هذا المنشور؟"),
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
                                              await FirebaseFirestore.instance
                                                  .collection('tajweed_post')
                                                  .doc(model
                                                      .id) // Reference to the specific competition document
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "حذف",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Iconsax.video_remove,
                                  color: AppColors.pinkColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: authProvider.currentAdmin != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTajweedPostScreen(),
                  ),
                );
              },
              child: const Icon(
                Iconsax.add,
                color: AppColors.whiteColor,
              ),
            )
          : null,
    );
  }
}
