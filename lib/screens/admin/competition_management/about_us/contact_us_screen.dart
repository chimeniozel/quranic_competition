import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // Method to launch email client or phone dialer
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اتصل بنا"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "للتواصل معنا",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text("contact@qurancontest.com"),
              onTap: () {
                _launchURL('mailto:contact@qurancontest.com');
              },
            ),
            GestureDetector(
              onTap: () {
                _launchURL('tel:+22220495770');
              },
              child: Container(
                child: const Row(
                  children: [
                    Icon(Icons.phone, color: Colors.green),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      "+222 20 49 57 70",
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.web, color: Colors.teal),
              title: const Text("www.qurancontest.com"),
              onTap: () {
                _launchURL('https://www.qurancontest.com');
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "تابعونا على وسائل التواصل الاجتماعي:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  onPressed: () {
                    _launchURL('https://www.facebook.com/qurancontest');
                  },
                ),
                IconButton(
                  icon: const Icon(Iconsax.call, color: Colors.green),
                  onPressed: () {
                    _launchURL('https://wa.me/213123456789');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.whatshot, color: Colors.pink),
                  onPressed: () {
                    _launchURL('https://www.instagram.com/qurancontest');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
