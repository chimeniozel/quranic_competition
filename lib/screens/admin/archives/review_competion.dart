import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/widgets/video_widget.dart';

class ReviewCompetion extends StatefulWidget {
  final String itemUrl;
  final String competitionId;
  final bool isImage;
  const ReviewCompetion({
    super.key,
    required this.itemUrl,
    required this.isImage,
    required this.competitionId,
  });

  @override
  State<ReviewCompetion> createState() => _ReviewCompetionState();
}

class _ReviewCompetionState extends State<ReviewCompetion> {
  @override
  Widget build(BuildContext context) {
    String itemUrl = widget.itemUrl;
    String competitionId = widget.competitionId;
    bool isImage = widget.isImage;
    return Consumer<AuthProviders>(builder: (context, authProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
            isImage ? 'معاينة الصورة' : 'معاينة الصورة',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(
            8.0,
          ),
          width: double.infinity,
          child: isImage
              ? Image.network(
                  itemUrl,
                  fit: BoxFit.contain,
                )
              : VideoWidget(videoSource: itemUrl),
        ),
        bottomNavigationBar: authProvider.user != null
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
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
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text("إلغاء"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Add your delete action here
                                if (isImage) {
                                  FirebaseFirestore.instance
                                      .collection("competitions")
                                      .doc(competitionId)
                                      .update({
                                    "archiveEntry.imagesURL":
                                        FieldValue.arrayRemove(
                                      [itemUrl],
                                    ),
                                  });
                                  Navigator.of(context).pop();
                                }
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
              )
            : null,
      );
    });
  }
}
