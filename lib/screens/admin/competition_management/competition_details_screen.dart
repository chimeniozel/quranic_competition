import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/admin/competition_management/competion_archive.dart';
import 'package:quranic_competition/screens/admin/competition_management/competition_result.dart';
import 'package:quranic_competition/screens/admin/competition_management/jury_results.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  final Competition competition;
  const CompetitionDetailsScreen({super.key, required this.competition});

  @override
  State<CompetitionDetailsScreen> createState() =>
      _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState extends State<CompetitionDetailsScreen> {
  final List<String> competitionTypes = [
    "المتسابقين الكبار",
    "المتسابقين الصغار"
  ];
  String? selectedType = "adult_inscription";
  String? selectedText = "المتسابقين الكبار";
  @override
  Widget build(BuildContext context) {
    Competition? currentCompetition =
        Provider.of<CompetitionProvider>(context, listen: true).competition;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 60,
        title: const Text(
          'تفاصيل المسابقة',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          //
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JuryResults(
                    competition: widget.competition,
                  ),
                ),
              );
            },
            child: const Column(
              children: [
                Icon(Iconsax.trend_up),
                Text(
                  "التصحيح اللجنة",
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<Competition?>(
          future: CompetitionService.getCompetition(
              widget.competition.competitionId.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              Competition competition = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "تاريخ البداية: ${competition.startDate != null ? Utils.arDateFormat(competition.startDate!) : 'غير متاح'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "تاريخ النهاية: ${competition.endDate != null ? Utils.arDateFormat(competition.endDate!) : 'غير متاح'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Text(
                    "المتسابقون:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
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
                      // hint: const Text("اختر فئة"),
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
                    height: 5.0,
                  ),
                  if (selectedType != null)
                    Expanded(
                      child: FutureBuilder<List<Inscription>>(
                        future: InscriptionService.fetchContestants(
                            competition, selectedType!),
                        builder: (context, snapshotInscription) {
                          if (snapshotInscription.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshotInscription.hasData &&
                              snapshotInscription.data!.isNotEmpty) {
                            return ListView.builder(
                              itemCount: snapshotInscription.data!.length,
                              itemBuilder: (context, index) {
                                Inscription inscription =
                                    snapshotInscription.data![index];
                                return GestureDetector(
                                  onLongPress: () async {
                                    // Show confirmation dialog to delete the competition
                                    await showDialog(
                                      context: context,
                                      builder: (context) => StatefulBuilder(
                                        builder: (context, setState) =>
                                            AlertDialog(
                                          title: const Text(
                                            'تحذير: حذف المتسابق',
                                            style: TextStyle(
                                                color: Colors
                                                    .red), // Change title color to red
                                          ),
                                          content: const Text(
                                            'هل أنت متأكد أنك تريد حذف هذا المتسابق ؟ هذا الإجراء لا يمكن التراجع عنه.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: const Text('إلغاء'),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor: Colors
                                                      .red, // Set background color to red
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  )),
                                              onPressed: () {
                                                List<dynamic>? roundList =
                                                    inscription.tashihMachaikhs
                                                        ?.firstRound;
                                                int correctedCount = 0;
                                                for (var element
                                                    in (roundList ?? [])) {
                                                  // Handle null roundList
                                                  try {
                                                    NoteResult noteResult;

                                                    // Check if it's an adult or child inscription and parse accordingly
                                                    if (selectedType ==
                                                        "adult_inscription") {
                                                      noteResult = NoteResult
                                                          .fromMapAdult(
                                                              element);
                                                    } else {
                                                      noteResult = NoteResult
                                                          .fromMapChild(
                                                              element);
                                                    }

                                                    // Safely check if the result is corrected
                                                    if (noteResult
                                                        .isCorrected!) {
                                                      correctedCount++;
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        "Error parsing NoteResult: $e");
                                                  }
                                                }
                                                if (currentCompetition !=
                                                        null &&
                                                    correctedCount !=
                                                        roundList!.length) {
                                                  // Delete the competition from Firestore
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'inscriptions')
                                                      .doc(competition
                                                          .competitionVirsion)
                                                      .collection(selectedType!)
                                                      .doc(inscription
                                                          .phoneNumber)
                                                      .delete()
                                                      .then((_) {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'تم حذف المتسابق بنجاح'),
                                                        backgroundColor:
                                                            AppColors
                                                                .primaryColor,
                                                      ),
                                                    );
                                                  }).catchError(
                                                    (error) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'خطأ في الحذف: $error'),
                                                          backgroundColor:
                                                              AppColors
                                                                  .grayColor,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                } else {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                  // Show error message if competition is not active
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'لا يمكنك حذف هذا المتسابق لأن المسابقة قد انتهت !.',
                                                      ),
                                                      backgroundColor:
                                                          AppColors.yellowColor,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: const Text(
                                                'حذف',
                                                style: TextStyle(
                                                    color: Colors
                                                        .white), // Set text color to white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 5.0),
                                    decoration: const BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 10.0,
                                          color: Colors.black12,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    "رقم التسجيل",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      "${inscription.idInscription}"),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    "الإسم الكامل",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      "${inscription.fullName}"),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                    "رقم الهاتف",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                      "${inscription.phoneNumber}"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        // if (inscription.isBaned!)
                                        //   Positioned(
                                        //     top: 7,
                                        //     left: -17,
                                        //     // bottom: 13,
                                        //     child: Transform.rotate(
                                        //       angle: -50 *
                                        //           3.141592653589793 /
                                        //           180, // Convert 30 degrees to radians
                                        //       child: Container(
                                        //         height: 15,
                                        //         width: 55,
                                        //         padding:
                                        //             const EdgeInsets.symmetric(
                                        //                 vertical: 2,
                                        //                 horizontal: 4),
                                        //         decoration: BoxDecoration(
                                        //           color: Colors
                                        //               .redAccent, // Use any color that stands out
                                        //           borderRadius:
                                        //               BorderRadius.circular(4),
                                        //         ),
                                        //         child: const Text(
                                        //           "محظور",
                                        //           textAlign: TextAlign.center,
                                        //           style: TextStyle(
                                        //             color: Colors.white,
                                        //             fontSize: 8,
                                        //             fontWeight: FontWeight.bold,
                                        //             fontStyle: FontStyle.italic,
                                        //             letterSpacing: 1.2,
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text("لا يوجد مترشحون"),
                            );
                          }
                        },
                      ),
                    ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to the upload archive screen

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompetionArchive(
                                  competition: competition,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "أرشيف المسابقة",
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
                            backgroundColor: AppColors.greenColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to the results screen

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompetitionResults(
                                  competition: competition,
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "نشر نتائج المسابقة",
                            style: TextStyle(
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("لا توجد مسابقة"),
              );
            }
          },
        ),
      ),
    );
  }
}
