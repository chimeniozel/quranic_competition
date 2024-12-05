import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:url_launcher/url_launcher.dart';

class JuryResultsFiles extends StatefulWidget {
  final Competition competition;
  const JuryResultsFiles({super.key, required this.competition});

  @override
  State<JuryResultsFiles> createState() => _JuryResultsFilesState();
}

class _JuryResultsFilesState extends State<JuryResultsFiles> {
  Users? selectedUsers;
  String? selectedType;
  String? selectedText;
  bool isLoading = false;

  Map<String, Map<String, List<String>>> participantsFiles = {};

  Future<void> fetchAllParticipantsFiles(String competitionRound) async {
    try {
      setState(() {
        isLoading = true;
      });
      String basePath =
          "/${widget.competition.competitionVersion}/تصحيح لجنة التحكيم/$competitionRound";

      Reference storageRef = FirebaseStorage.instance.ref().child(basePath);
      ListResult result = await storageRef.listAll();

      for (var prefix in result.prefixes) {
        String participantName = prefix.name;
        Map<String, List<String>> fileUrls =
            await _fetchFilesForParticipant(prefix.fullPath);

        participantsFiles[participantName] = {
          "names": fileUrls["names"]!,
          "urls": fileUrls["urls"]!,
        };
      }

      setState(() {
        participantsFiles = participantsFiles;
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // failure Snack Bar
      final failureSnackBar = SnackBar(
        content: Text("خطأ في جلب ملفات جميع المشاركين: $e"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.pinkColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
    }
  }

  Future<Map<String, List<String>>> _fetchFilesForParticipant(
      String path) async {
    List<String> urls = [];
    List<String> names = [];
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(path);
      ListResult result = await storageRef.listAll();

      for (var ref in result.items) {
        String name = ref.name;
        String url = await ref.getDownloadURL();
        names.add(name);
        urls.add(url);
      }
    } catch (e) {
      // failure Snack Bar
      final failureSnackBar = SnackBar(
        content: Text("خطأ في جلب ملفات المشارك من المسار: $path, $e"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.pinkColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
    }
    return {
      "urls": urls,
      "names": names,
    };
  }

  // New delete method
  Future<void> deleteFile(String participantName, String fileName) async {
    // Confirm deletion
    bool confirm = await _confirmDelete(fileName);
    if (!confirm) return;

    try {
      // Construct the full path to the file in Firebase Storage
      String filePath =
          "/${widget.competition.competitionVersion}/تصحيح لجنة التحكيم/${selectedText!}/$participantName/$fileName";
      Reference fileRef = FirebaseStorage.instance.ref().child(filePath);

      // Delete the file
      await fileRef.delete();

      // Update the local participantsFiles map
      setState(() {
        int fileIndex =
            participantsFiles[participantName]!["names"]!.indexOf(fileName);
        participantsFiles[participantName]!["names"]!.removeAt(fileIndex);
        participantsFiles[participantName]!["urls"]!.removeAt(fileIndex);
      });
      // saccess Snack Bar
      final saccessSnackBar = SnackBar(
        content: const Text("تم حذف الملف بنجاح"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.greenColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(saccessSnackBar);
    } catch (e) {
      // failure Snack Bar
      final failureSnackBar = SnackBar(
        content: Text("خطأ في حذف الملف: $e"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.pinkColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
    }
  }

  Future<bool> _confirmDelete(String fileName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("تأكيد الحذف"),
              content: Text("هل أنت متأكد أنك تريد حذف $fileName؟"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("إلغاء"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("حذف"),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('تصحيح لجنة التحكيم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: AppColors.whiteColor,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: DropdownButton<String>(
                      hint: const Text("اختر فئة"),
                      underline: Container(),
                      isExpanded: true,
                      value: selectedText,
                      items: ["التصفيات الأولى", "التصفيات النهائية"]
                          .map(
                            (String type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          participantsFiles = {};
                          selectedText = value; // Store selected type
                          fetchAllParticipantsFiles(value!);
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  )
                : participantsFiles.isEmpty && selectedText != null
                    ? const Expanded(
                        child: Center(
                          child: Text(
                            "لم تنتهي لجنة التحكيم من التصحيح !",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                        itemCount: participantsFiles.length,
                        itemBuilder: (context, index) {
                          String participantName =
                              participantsFiles.keys.elementAt(index);
                          List<String> fileNames =
                              participantsFiles[participantName]!["names"]!;
                          List<String> fileUrls =
                              participantsFiles[participantName]!["urls"]!;

                          return ExpansionTile(
                            title: Text(
                              participantName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            children:
                                List.generate(fileNames.length, (fileIndex) {
                              String fileName = fileNames[fileIndex];
                              String fileUrl = fileUrls[fileIndex];

                              return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                margin: const EdgeInsets.only(bottom: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: AppColors.whiteColor,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(fileName),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              child: IconButton(
                                            icon: const Icon(
                                              Iconsax.document_download5,
                                              color: AppColors.primaryColor,
                                            ),
                                            onPressed: () async {
                                              Uri url = Uri.parse(fileUrl);

                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url,
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              } else {
                                                print('Could not launch $url');
                                              }
                                            },
                                          )),
                                          if (widget.competition.isActive!)
                                            Expanded(
                                              child: IconButton(
                                                icon: const Icon(
                                                  IconlyBold.delete,
                                                  color: AppColors.pinkColor,
                                                ),
                                                onPressed: () {
                                                  deleteFile(participantName,
                                                      fileName);
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
                          );
                        },
                      )),
          ],
        ),
      ),
    );
  }
}
