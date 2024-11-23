import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/about_us_model.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  // Method to launch email client or phone dialer
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication, // Ensures it opens in the Facebook app if available
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("من نحن"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder<AboutUsModel?>(
              future: CompetitionService.getAboutUs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  AboutUsModel model = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: AppColors.grayLigthColor,
                          backgroundImage:
                              AssetImage('assets/images/logos/logo.png'),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "عن المسابقة",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.description!,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "تابعونا على وسائل التواصل الاجتماعي:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            child: SizedBox(
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  'assets/images/logos/facebook.png',
                                ),
                              ),
                            ),
                            onTap: () {
                              _launchURL(model.facebookUrl!);
                            },
                          ),
                          GestureDetector(
                            child: SizedBox(
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  'assets/images/logos/whatsapp.png',
                                ),
                              ),
                            ),
                            onTap: () {
                              _launchURL(
                                  'https://wa.me/${model.whatsappPhoneNumber}');
                            },
                          ),
                          GestureDetector(
                            child: SizedBox(
                              width: 40,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.asset(
                                  'assets/images/logos/youtube.png',
                                ),
                              ),
                            ),
                            onTap: () {
                              _launchURL(model.youtubeUrl!);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ : ${snapshot.error}',
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'لا توجد معلومات',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
