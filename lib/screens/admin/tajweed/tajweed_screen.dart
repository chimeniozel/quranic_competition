import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/screens/admin/tajweed/post/tajweed_post_screen.dart';
import 'package:quranic_competition/screens/admin/tajweed/video/tajweed_video_screen.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});
  @override
  TajweedScreenState createState() => TajweedScreenState();
}

class TajweedScreenState extends State<TajweedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("أحكام التجويد"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the competition managment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TajweedPostScreen(),
                  ),
                );
              },
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/post.png',
                      width: 70,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'المناشير التجويدية',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the competition managment
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TajweedVideoScreen(),
                  ),
                );
              },
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(
                  10.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/archive_video.png',
                      width: 70,
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    const Text(
                      'الفيديوهات',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
