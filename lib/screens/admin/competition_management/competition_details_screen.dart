import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
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
  @override
  Widget build(BuildContext context) {
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
                  "التصحيح",
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
                  Expanded(
                    child: FutureBuilder<List<Inscription>>(
                      future: InscriptionService.fetchContestants(
                        competition,
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
                                            "رقم التسجيل",
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
