import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor: AppColors.grayLigthColor,
                  backgroundImage: AssetImage('assets/images/logos/logo.png'),
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
              const Text(
                "مسابقة أهل القرآن الواتسابية هي أول مسابقة قرآنية واتسابية مرخصة بالبلد تحت رقم 043/2022 تهدف بالاعتناء بالقرآن الكريم حفظا و تجويدا وأداء.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              const Text(
                "تابعونا على وسائل التواصل الاجتماعي:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      _launchURL(
                          'https://web.facebook.com/profile.php?id=100076059729355&mibextid=ZbWKwL&_rdc=1&_rdr');
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
                      _launchURL('https://wa.me/22222441644');
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
                      _launchURL('https://www.youtube.com/@ehelcoran');
                    },
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
