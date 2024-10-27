import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionResults extends StatefulWidget {
  final Competition competition;
  const CompetitionResults({super.key, required this.competition});

  @override
  CompetitionResultsState createState() => CompetitionResultsState();
}

class CompetitionResultsState extends State<CompetitionResults> {
  bool isLoadingFirst = false;
  bool isLoadingLast = false;
  final List<String> competitionPhases = [
    "التصفيات الأولى",
    "التصفيات النهائية"
  ];

  final List<String> competitionTypes = [
    "المتسابقين الكبار",
    "المتسابقين الصغار"
  ];
  String? selectedType;
  String? selectedText;
  String? selectedRound = "التصفيات الأولى";
  bool isPassedFirstRound = false;

  String query = "";

//   File? firstSelectedFile;
//   File? lastSelectedFile;
//   String? firstFileName;
//   String? lastFileName;
//   double firstUploadProgress = 0.0;
//   double lastUploadProgress = 0.0;
//   List<String> fileUrlsFirst = [];
//   List<String> fileNamesFirst = [];

//   List<String> fileUrlsLast = [];
//   List<String> fileNamesLast = [];

//   Future<void> pickFile(bool isFirst) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['xls', 'xlsx'],
//     );
//     if (result != null) {
//       if (isFirst) {
//         setState(() {
//           firstSelectedFile = File(result.files.single.path!);
//           firstFileName = result.files.single.name;
//         });
//       } else {
//         setState(() {
//           lastSelectedFile = File(result.files.single.path!);
//           lastFileName = result.files.single.name;
//         });
//       }
//     }
//   }

//   Future<void> uploadFile(
//       File file, Competition competition, bool isFirst) async {
//     try {
//       Reference storageReference;

//       String fileName = file.path.split('/').last;
//       String folderPath = isFirst ? "نتائج التصفيات" : "النتائج النهائية";

//       setState(() {
//         if (isFirst) {
//           firstIsUploading = true;
//           firstUploadProgress = 0.0;
//         } else {
//           lastIsUploading = true;
//           lastUploadProgress = 0.0;
//         }
//       });

//       storageReference = FirebaseStorage.instance.ref().child(
//           "${competition.competitionVirsion}/نتائج المسابقة/$folderPath/$fileName");

//       UploadTask uploadTask = storageReference.putFile(file);

//       uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//         setState(() {
//           if (isFirst) {
//             firstUploadProgress =
//                 snapshot.bytesTransferred / snapshot.totalBytes;
//           } else {
//             lastUploadProgress =
//                 snapshot.bytesTransferred / snapshot.totalBytes;
//           }
//         });
//       });

//       await uploadTask.whenComplete(() async {
//         if (isFirst) {
//           setState(() {
//             firstIsUploading = false;
//           });
//         } else {
//           setState(() {
//             lastIsUploading = false;
//           });
//         }

//         // استخراج البيانات من رابط الملف
//         String fileURL = await storageReference.getDownloadURL();
//         await extractDataFromExcel(fileURL, isFirst);

//         // استدعاء الدالة لجلب الملفات المحدثة
//         fetchUploadedFirst();
//         fetchUploadedLast();
//       });
//     } catch (e) {
//       final failureSnackBar = SnackBar(
//         content: Text("فشل في رفع الملف: $e"),
//         action: SnackBarAction(
//           label: 'تراجع',
//           onPressed: () {},
//         ),
//         backgroundColor: AppColors.yellowColor,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
//     }
//   }

//   Future<void> extractDataFromExcel(String fileUrl, bool isFrist) async {
//     try {
//       // جلب البيانات من رابط الملف
//       final response = await http.get(Uri.parse(fileUrl));

//       if (response.statusCode == 200) {
//         final bytes = response.bodyBytes;
//         var excel = Excel.decodeBytes(bytes);

//         for (var table in excel.tables.keys) {
//           var sheet = excel.tables[table];
//           if (sheet != null && sheet.rows.isNotEmpty) {
//             // افتراض أن الصف الأول يحتوي على أسماء الأعمدة
//             List<String> columnNames = sheet.rows.first
//                 .map((cell) => cell?.value?.toString() ?? '')
//                 .toList();

//             // استخراج البيانات من الصفوف التالية
//             for (var i = 1; i < sheet.rows.length; i++) {
//               var row = sheet.rows[i];
//               Map<String, dynamic> data = {};

//               for (var j = 0; j < row.length; j++) {
//                 String columnName = columnNames[j];
//                 data[columnName] = row[j]?.value?.toString() ?? '';
//               }

//               if (isFrist) {
//                 // رفع البيانات إلى قاعدة بيانات فايربيز
//                 await FirebaseFirestore.instance
//                     .collection('results')
//                     .doc(widget.competition.competitionVirsion)
//                     .collection("نتائج التصفيات")
//                     .add(data);
//               } else {
//                 // رفع البيانات إلى قاعدة بيانات فايربيز
//                 await FirebaseFirestore.instance
//                     .collection('results')
//                     .doc(widget.competition.competitionVirsion)
//                     .collection("النتائج النهائية")
//                     .add(data);
//               }
//             }
//           }
//         }
//       } else {
//         print('فشل في جلب الملف: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("فشل في استخراج البيانات من ملف Excel: $e");
//     }
//   }

//   Future<void> _confirmDelete(String fileName, bool isFirst) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('تأكيد الحذف'),
//           content: const Text('هل أنت متأكد أنك تريد حذف هذا الملف؟'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: const Text('إلغاء'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: const Text('حذف'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm == true) {
//       _deleteFile(fileName, isFirst);
//     }
//   }

//   Future<void> _deleteFile(String fileName, bool isFirst) async {
//     String folderPath = isFirst ? "نتائج التصفيات" : "النتائج النهائية";
//     try {
//       Reference storageRef = FirebaseStorage.instance.ref().child(
//           "/${widget.competition.competitionVirsion}/نتائج المسابقة/$folderPath/$fileName");

//       await storageRef.delete().whenComplete(() async {
//         if (isFirst) {
//           // رفع البيانات إلى قاعدة بيانات فايربيز
//           var querySnapshot = await FirebaseFirestore.instance
//               .collection('results')
//               .doc(widget.competition.competitionVirsion)
//               .collection("نتائج التصفيات")
//               .get();
//           for (var doc in querySnapshot.docs) {
//             await doc.reference.delete();
//           }
//         } else {
//           // رفع البيانات إلى قاعدة بيانات فايربيز   النتائج النهائية
//           var querySnapshot = await FirebaseFirestore.instance
//               .collection('results')
//               .doc(widget.competition.competitionVirsion)
//               .collection("النتائج النهائية")
//               .get();
//           for (var doc in querySnapshot.docs) {
//             await doc.reference.delete();
//           }
//         }
//       });

// // استدعاء الدالة لجلب الملفات المحدثة
//       fetchUploadedFirst();
//       fetchUploadedLast();

//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('تم حذف الملف بنجاح.'),
//       ));
//     } catch (e) {
//       print("خطأ في حذف الملف: $e");
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('فشل في حذف الملف.'),
//       ));
//     }
//   }

//   Future<void> _launchURL(String url) async {
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   void initState() {
//     // fetchUploadedFirst();
//     // fetchUploadedLast();
//     super.initState();
//   }

//   Future<void> fetchUploadedFirst() async {
//     try {
//       String path =
//           "${widget.competition.competitionVirsion}/نتائج المسابقة/نتائج التصفيات/";
//       Reference storageRef = FirebaseStorage.instance.ref().child(path);
//       ListResult result = await storageRef.listAll();
//       List<String> urls = [];
//       List<String> names = [];
//       for (var ref in result.items) {
//         String url = await ref.getDownloadURL();
//         urls.add(url);
//         names.add(ref.name);
//       }

//       setState(() {
//         fileUrlsFirst = urls;
//         fileNamesFirst = names;
//       });
//     } catch (e) {
//       print("خطأ في جلب الملفات المرفوعة: $e");
//     }
//   }

//   Future<void> fetchUploadedLast() async {
//     try {
//       String path =
//           "${widget.competition.competitionVirsion}/نتائج المسابقة/النتائج النهائية/";
//       Reference storageRef = FirebaseStorage.instance.ref().child(path);
//       ListResult result = await storageRef.listAll();
//       List<String> urls = [];
//       List<String> names = [];
//       for (var ref in result.items) {
//         String url = await ref.getDownloadURL();
//         urls.add(url);
//         names.add(ref.name);
//       }

//       setState(() {
//         fileUrlsLast = urls;
//         fileNamesLast = names;
//       });
//     } catch (e) {
//       print("خطأ في جلب الملفات المرفوعة: $e");
//     }
//   }

  @override
  Widget build(BuildContext context) {
    CompetitionProvider competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          // minimumSize: const Size(double.infinity, 45.0),
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.all(5.0)),
                      onPressed: () async {
                        setState(() {
                          isLoadingFirst = true;
                        });
                        Competition? competition =
                            Provider.of<CompetitionProvider>(context,
                                    listen: false)
                                .competition;
                        bool isCorrected =
                            await CompetitionService.publishResults(
                                competition!.competitionVirsion!,
                                "التصفيات الأولى");
                        if (isCorrected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم حساب المعدلات الأولية بنجاح.',
                              ),
                              backgroundColor: AppColors.greenColor,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'لم تنتهي لجنة التحكيم من التصحيح',
                              ),
                              backgroundColor: AppColors.yellowColor,
                            ),
                          );
                        }
                        setState(() {
                          isLoadingFirst = false;
                        });
                      },
                      child: isLoadingFirst
                          ? const CircularProgressIndicator(
                              color: AppColors.whiteColor,
                            )
                          : const Text(
                              'حساب ونشر النتائج الأولية',
                              style: TextStyle(
                                color: AppColors.whiteColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        // minimumSize: const Size(double.infinity, 45.0),
                        padding: const EdgeInsets.all(5.0),
                      ),
                      onPressed: () async {
                        setState(() {
                          isLoadingLast = true;
                        });
                        Competition? competition =
                            Provider.of<CompetitionProvider>(context,
                                    listen: false)
                                .competition;
                        bool isCorrected =
                            await CompetitionService.publishResults(
                                competition!.competitionVirsion!,
                                "التصفيات النهائية");
                        if (isCorrected) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم حساب المعدلات الأولية بنجاح.',
                              ),
                              backgroundColor: AppColors.greenColor,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'لم تنتهي لجنة التحكيم من التصحيح',
                              ),
                              backgroundColor: AppColors.yellowColor,
                            ),
                          );
                        }
                        setState(() {
                          isLoadingLast = false;
                        });
                      },
                      child: isLoadingLast
                          ? const CircularProgressIndicator(
                              color: AppColors.whiteColor,
                            )
                          : const Text(
                              'حساب ونشر النتائج النهائية',
                              style: TextStyle(
                                color: AppColors.whiteColor,
                              ),
                            ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
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
                child: DropdownButton(
                  // hint: const Text("اختر مرحلة"),
                  isExpanded: true,
                  underline: Container(),
                  value: selectedRound,
                  items: competitionPhases
                      .map(
                        (String phase) => DropdownMenuItem(
                          value: phase,
                          child: Text(phase),
                        ),
                      )
                      .toList(),
                  onChanged: (String? phase) {
                    setState(() {
                      selectedRound = phase;
                      if (phase == "التصفيات الأولى") {
                        isPassedFirstRound = false;
                      } else {
                        isPassedFirstRound = true;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
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
                child: DropdownButton(
                  hint: const Text("اختر فئة"),
                  isExpanded: true,
                  underline: Container(),
                  value: selectedText,
                  items: competitionTypes
                      .map(
                        (String phase) => DropdownMenuItem(
                          value: phase,
                          child: Text(phase),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    setState(() {
                      if (value == "المتسابقين الكبار") {
                        selectedText = value;
                        selectedType = "adult_inscription";
                      } else {
                        selectedType = "child_inscription";
                        selectedText = value;
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              if (selectedRound != null)
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: 'البحث عن متسابق',
                    hintText: 'البحث عن متسابق',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Iconsax.search_normal,
                      color: Colors.black,
                      size: 18,
                    ),
                    // suffixIcon: widget.suffixIcon,
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    floatingLabelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                  },
                ),
              const SizedBox(
                height: 5.0,
              ),
              if (selectedType != null)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: FutureBuilder<List<Inscription>>(
                    future: CompetitionService.getResults(
                      competitionVersion: competitionProvider
                          .competition!.competitionVirsion
                          .toString(),
                      competitionType: selectedType!,
                      competitionRound: selectedRound!,
                      isPassedFirstRound: isPassedFirstRound,
                      query: query,
                    ),
                    builder: (context, snapshotInscription) {
                      if (snapshotInscription.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshotInscription.hasData &&
                          snapshotInscription.data!.isNotEmpty) {
                        return ListView.builder(
                          itemCount: snapshotInscription.data!.length,
                          itemBuilder: (context, index) {
                            Inscription inscription =
                                snapshotInscription.data![index];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.only(bottom: 5.0),
                              decoration: const BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0.0, 2.0),
                                    blurRadius: 10.0,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "رقم التسجيل",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("${inscription.idInscription}"),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "الإسم الثلاثي",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("${inscription.fullName}"),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const Text(
                                          "المعدل العام",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(inscription.resultFirstRound!
                                            .toStringAsFixed(2)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text("لا توجد نتائج"));
                      }
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
