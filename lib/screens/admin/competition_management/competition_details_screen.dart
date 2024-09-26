import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/screens/admin/competition_management/competion_archive.dart';
import 'package:quranic_competition/screens/admin/competition_management/upload_archive.dart';
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
  List<Users> juryUsers = [];
  Users? selectedUsers;
  String? selectedType;
  String? selectedText;

  @override
  void initState() {
    getJuryUsers();
    super.initState();
  }

  Future<void> getJuryUsers() async {
    List<Users> jury = await CompetitionService.getJuryUsers();
    setState(() {
      juryUsers = jury;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('تفاصيل المسابقة'),
        actions: [
          const Text("أضف أرشيف"),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UploadArchive(
                    competition: widget.competition,
                    competitionVirsion:
                        widget.competition.competitionVirsion.toString(),
                  ),
                ),
              );
            },
            icon: const Icon(Iconsax.add_circle),
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
                  Expanded(
                    child: FutureBuilder<List<Inscription>>(
                      future: InscriptionService.fetchContestants(
                        competition.competitionVirsion.toString(),
                        competition.competitionTypes![0],
                      ),
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
                              return Container(
                                padding: const EdgeInsets.all(
                                  8.0,
                                ),
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
                                            "رقم المتسابق",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text("${inscription.idInscription}"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "الإسم الكامل",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text("${inscription.fullName}"),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "رقم الهاتف",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text("${inscription.phoneNumber}"),
                                        ],
                                      ),
                                    ),
                                  ],
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
                    height: 10.0,
                  ),
                  const Text(
                    "لوائح المصححين:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setState) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
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
                                    items: ["فئة الكبار", "فئة الصغار"]
                                        .map(
                                          (String type) =>
                                              DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(
                                              type,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == "فئة الكبار") {
                                        setState(() {
                                          selectedText = value;
                                          selectedType = "adult_inscription";
                                        });
                                      } else {
                                        setState(() {
                                          selectedText = value;
                                          selectedType = "child_inscription";
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                    color: AppColors.whiteColor,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: DropdownButton<Users>(
                                    hint: const Text("اختر شيخا"),
                                    underline: Container(),
                                    isExpanded: true,
                                    value: selectedUsers,
                                    items: juryUsers
                                        .map(
                                          (Users user) =>
                                              DropdownMenuItem<Users>(
                                            value: user,
                                            child: Text(
                                              user.fullName,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (selectedType != null) {
                                        setState(() {
                                          selectedUsers = value;
                                        });
                                      } else {
                                        // snack bar
                                        // Snackbar for failure
                                        final successSnackBar = SnackBar(
                                          content: const Text(
                                              'اختر فئة ثم اختر الشيخ'),
                                          action: SnackBarAction(
                                            label: 'تراجع',
                                            onPressed: () {
                                              // Perform some action
                                            },
                                          ),
                                          backgroundColor: Colors.red,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(successSnackBar);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          selectedUsers != null
                              ? Flexible(
                                  child: FutureBuilder<List<Inscription>>(
                                    future: InscriptionService
                                        .fetchContestantsByJury(
                                            competition.competitionVirsion
                                                .toString(),
                                            selectedType!,
                                            selectedUsers!.fullName),
                                    builder: (context, snapshotInscription) {
                                      if (snapshotInscription.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshotInscription.hasData &&
                                          snapshotInscription
                                              .data!.isNotEmpty) {
                                        return ListView.builder(
                                          itemCount:
                                              snapshotInscription.data!.length,
                                          itemBuilder: (context, index) {
                                            Inscription inscription =
                                                snapshotInscription
                                                    .data![index];
                                            return Container(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              margin: const EdgeInsets.only(
                                                  bottom: 5.0),
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
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                          "رقم المتسابق",
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
                                                          "المجموع",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(inscription
                                                            .result![
                                                                selectedUsers!
                                                                    .fullName]
                                                            .toString()),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return const Center(
                                          child: Text(
                                              "لم ينتهي هذا الشيخ من التصحيح"),
                                        );
                                      }
                                    },
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
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
                          onPressed: () {},
                          child: const Text(
                            "نتائج المسابقة",
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
