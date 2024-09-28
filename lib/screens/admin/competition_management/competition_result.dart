import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class CompetitionResults extends StatefulWidget {
  final Competition competition;
  const CompetitionResults({super.key, required this.competition});

  @override
  CompetitionResultsState createState() => CompetitionResultsState();
}

class CompetitionResultsState extends State<CompetitionResults> {
  bool firstIsUploading = false;
  bool lastIsUploading = false;
  File? firstSelectedFile;
  File? lastSelectedFile;
  String? firstFileName;
  String? lastFileName;
  double firstUploadProgress = 0.0;
  double lastUploadProgress = 0.0;
  List<String> fileUrls = [];
  List<String> fileNames = [];

  Future<void> pickFile(bool isFirst) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );
    if (result != null) {
      if (isFirst) {
        setState(() {
          firstSelectedFile = File(result.files.single.path!);
          firstFileName = result.files.single.name;
        });
      } else {
        setState(() {
          lastSelectedFile = File(result.files.single.path!);
          lastFileName = result.files.single.name;
        });
      }
    }
  }

  Future<void> uploadFile(
      File file, Competition competition, bool isFirst) async {
    try {
      Reference storageReference;

      String fileName = file.path.split('/').last;
      if (isFirst) {
        setState(() {
          firstIsUploading = true;
          firstUploadProgress = 0.0;
        });
        storageReference = FirebaseStorage.instance.ref().child(
            "${competition.competitionVirsion}/نتائج المسابقة/نتائج التصفيات/$fileName");
      } else {
        setState(() {
          lastIsUploading = true;
          lastUploadProgress = 0.0;
        });
        storageReference = FirebaseStorage.instance.ref().child(
            "${competition.competitionVirsion}/نتائج المسابقة/النتائج النهائية/$fileName");
      }

      UploadTask uploadTask = storageReference.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (isFirst) {
          setState(() {
            firstUploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          });
        } else {
          setState(() {
            lastUploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask.whenComplete(() async {
        if (isFirst) {
          setState(() {
            firstIsUploading = false;
          });
        } else {
          setState(() {
            lastIsUploading = false;
          });
        }

        // استخراج البيانات من رابط الملف
        String fileURL = await storageReference.getDownloadURL();
        await extractDataFromExcel(fileURL, isFirst);
      });

      String fileURL = await storageReference.getDownloadURL();
      print("رابط الملف: $fileURL");
    } catch (e) {
      final failureSnackBar = SnackBar(
        content: Text("فشل في رفع الملف: $e"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.yellowColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
    }
  }

  Future<void> extractDataFromExcel(String fileUrl, bool isFrist) async {
    try {
      // جلب البيانات من رابط الملف
      final response = await http.get(Uri.parse(fileUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet != null && sheet.rows.isNotEmpty) {
            // افتراض أن الصف الأول يحتوي على أسماء الأعمدة
            List<String> columnNames = sheet.rows.first
                .map((cell) => cell?.value?.toString() ?? '')
                .toList();

            // استخراج البيانات من الصفوف التالية
            for (var i = 1; i < sheet.rows.length; i++) {
              var row = sheet.rows[i];
              Map<String, dynamic> data = {};

              for (var j = 0; j < row.length; j++) {
                String columnName = columnNames[j];
                data[columnName] = row[j]?.value?.toString() ?? '';
              }

              if (isFrist) {
                // رفع البيانات إلى قاعدة بيانات فايربيز
                await FirebaseFirestore.instance
                    .collection('results')
                    .doc(widget.competition.competitionVirsion)
                    .collection("نتائج التصفيات")
                    .doc("نتائج التصفيات")
                    .set(data);
              } else {
                // رفع البيانات إلى قاعدة بيانات فايربيز
                await FirebaseFirestore.instance
                    .collection('results')
                    .doc(widget.competition.competitionVirsion)
                    .collection("النتائج النهائية")
                    .doc("النتائج النهائية")
                    .set(data);
              }
            }
          }
        }
      } else {
        print('فشل في جلب الملف: ${response.statusCode}');
      }
    } catch (e) {
      print("فشل في استخراج البيانات من ملف Excel: $e");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("نتائج ${widget.competition.competitionVirsion.toString()}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نتائج التصفيات الأولية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "قم برفع ملف",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5.0,
            ),
            if (firstFileName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "الملف المختار: $firstFileName",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            if (firstIsUploading)
              Column(
                children: [
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: firstUploadProgress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primaryColor,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 10),
                  Text("${(firstUploadProgress * 100).toStringAsFixed(2)}%"),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      pickFile(true);
                    },
                    child: const Text(
                      'ملف التصفيات',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                if (firstSelectedFile != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        if (firstSelectedFile != null) {
                          uploadFile(
                              firstSelectedFile!, widget.competition, true);
                        } else {
                          final failureSnackBar = SnackBar(
                            content:
                                const Text('الرجاء تحديد ملف Excel أولاً.'),
                            action: SnackBarAction(
                              label: 'تراجع',
                              onPressed: () {},
                            ),
                            backgroundColor: AppColors.yellowColor,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(failureSnackBar);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'رفع الملف',
                            style: TextStyle(
                              color: AppColors.whiteColor,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Iconsax.document_upload,
                            size: 24,
                            color: AppColors.whiteColor,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'نتائج التصفيات النهائية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              "قم برفع ملف",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5.0,
            ),
            if (lastFileName != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "الملف المختار: $lastFileName",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            if (lastIsUploading)
              Column(
                children: [
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: lastUploadProgress,
                    backgroundColor: Colors.grey[200],
                    color: AppColors.primaryColor,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 10),
                  Text("${(lastUploadProgress * 100).toStringAsFixed(2)}%"),
                ],
              ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      pickFile(false);
                    },
                    child: const Text(
                      'الملف النهائي',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                if (lastSelectedFile != null)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: () {
                        if (lastSelectedFile != null) {
                          uploadFile(
                              lastSelectedFile!, widget.competition, false);
                        } else {
                          final failureSnackBar = SnackBar(
                            content:
                                const Text('الرجاء تحديد ملف Excel أولاً.'),
                            action: SnackBarAction(
                              label: 'تراجع',
                              onPressed: () {},
                            ),
                            backgroundColor: AppColors.yellowColor,
                          );
                          ScaffoldMessenger.of(context)
                              .showSnackBar(failureSnackBar);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'رفع الملف',
                            style: TextStyle(
                              color: AppColors.whiteColor,
                            ),
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Icon(
                            Iconsax.document_upload,
                            size: 24,
                            color: AppColors.whiteColor,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
