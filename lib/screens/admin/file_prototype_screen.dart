import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePrototypeScreen extends StatefulWidget {
  const FilePrototypeScreen({super.key});

  @override
  State<FilePrototypeScreen> createState() => _FilePrototypeScreenState();
}

class _FilePrototypeScreenState extends State<FilePrototypeScreen> {
  List<String> fileUrls = [];

  List<String> fileNames = [];

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> fetchUploaded() async {
    try {
      String path = "Prototype/";
      Reference storageRef = FirebaseStorage.instance.ref().child(path);
      ListResult result = await storageRef.listAll();
      List<String> urls = [];
      List<String> names = [];
      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        urls.add(url);
        names.add(ref.name);
      }

      setState(() {
        fileUrls = urls;
        fileNames = names;
      });
    } catch (e) {
      print("خطأ في جلب الملفات المرفوعة: $e");
    }
  }

  @override
  void initState() {
    fetchUploaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('نماذج الملفات'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: fileNames.length,
          itemBuilder: (context, index) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: AppColors.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackColor.withOpacity(.3),
                      blurRadius: 1.0,
                      spreadRadius: 2.0,
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 1),
                    ),
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fileNames[index],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Iconsax.document_download5,
                      color: AppColors.primaryColor,
                      size: 30.0,
                    ),
                    onPressed: () {
                      _launchURL(fileUrls[index]);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
