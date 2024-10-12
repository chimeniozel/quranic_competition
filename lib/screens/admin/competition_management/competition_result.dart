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
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  List<String> fileUrlsFirst = [];
  List<String> fileNamesFirst = [];

  List<String> fileUrlsLast = [];
  List<String> fileNamesLast = [];

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
      String folderPath = isFirst ? "نتائج التصفيات" : "النتائج النهائية";

      setState(() {
        if (isFirst) {
          firstIsUploading = true;
          firstUploadProgress = 0.0;
        } else {
          lastIsUploading = true;
          lastUploadProgress = 0.0;
        }
      });

      storageReference = FirebaseStorage.instance.ref().child(
          "${competition.competitionVirsion}/نتائج المسابقة/$folderPath/$fileName");

      UploadTask uploadTask = storageReference.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          if (isFirst) {
            firstUploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          } else {
            lastUploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          }
        });
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

        // استدعاء الدالة لجلب الملفات المحدثة
        fetchUploadedFirst();
        fetchUploadedLast();
      });
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
                    .add(data);
              } else {
                // رفع البيانات إلى قاعدة بيانات فايربيز
                await FirebaseFirestore.instance
                    .collection('results')
                    .doc(widget.competition.competitionVirsion)
                    .collection("النتائج النهائية")
                    .add(data);
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

  bool isLoading = true;

  Future<void> _confirmDelete(String fileName, bool isFirst) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا الملف؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _deleteFile(fileName, isFirst);
    }
  }

  Future<void> _deleteFile(String fileName, bool isFirst) async {
    String folderPath = isFirst ? "نتائج التصفيات" : "النتائج النهائية";
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          "/${widget.competition.competitionVirsion}/نتائج المسابقة/$folderPath/$fileName");

      await storageRef.delete().whenComplete(() async {
        if (isFirst) {
          // رفع البيانات إلى قاعدة بيانات فايربيز
          var querySnapshot = await FirebaseFirestore.instance
              .collection('results')
              .doc(widget.competition.competitionVirsion)
              .collection("نتائج التصفيات")
              .get();
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        } else {
          // رفع البيانات إلى قاعدة بيانات فايربيز   النتائج النهائية
          var querySnapshot = await FirebaseFirestore.instance
              .collection('results')
              .doc(widget.competition.competitionVirsion)
              .collection("النتائج النهائية")
              .get();
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        }
      });

// استدعاء الدالة لجلب الملفات المحدثة
      fetchUploadedFirst();
      fetchUploadedLast();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم حذف الملف بنجاح.'),
      ));
    } catch (e) {
      print("خطأ في حذف الملف: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('فشل في حذف الملف.'),
      ));
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    fetchUploadedFirst();
    fetchUploadedLast();
    super.initState();
  }

  Future<void> fetchUploadedFirst() async {
    try {
      String path =
          "${widget.competition.competitionVirsion}/نتائج المسابقة/نتائج التصفيات/";
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
        fileUrlsFirst = urls;
        fileNamesFirst = names;
      });
    } catch (e) {
      print("خطأ في جلب الملفات المرفوعة: $e");
    }
  }

  Future<void> fetchUploadedLast() async {
    try {
      String path =
          "${widget.competition.competitionVirsion}/نتائج المسابقة/النتائج النهائية/";
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
        fileUrlsLast = urls;
        fileNamesLast = names;
      });
    } catch (e) {
      print("خطأ في جلب الملفات المرفوعة: $e");
    }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نتائج التصفيات الأولية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10.0,
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
              const SizedBox(
                height: 10.0,
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
              const SizedBox(height: 20),
              const Text(
                "الملفات المرفوعة:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  itemCount: fileNamesFirst.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(fileNamesFirst[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Iconsax.document_download5,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              _launchURL(fileUrlsFirst[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              IconlyBold.delete,
                              color: AppColors.pinkColor,
                            ),
                            onPressed: () {
                              _confirmDelete(fileNamesFirst[index], true);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "النتائج النهائية",
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: fileNamesLast.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(fileNamesLast[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Iconsax.document_download5,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              _launchURL(fileUrlsLast[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              IconlyBold.delete,
                              color: AppColors.pinkColor,
                            ),
                            onPressed: () {
                              _confirmDelete(fileNamesLast[index], false);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
