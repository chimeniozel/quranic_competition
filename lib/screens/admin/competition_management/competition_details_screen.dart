import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  final String competitionId;
  const CompetitionDetailsScreen({super.key, required this.competitionId});

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
        title: const Text('تفاصيل المسابقة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Competition?>(
          future: CompetitionService.getCompetition(widget.competitionId),
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
                    "المترشحون:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  FutureBuilder<List<Inscription>>(
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
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshotInscription.data!.length,
                            itemBuilder: (context, index) {
                              Inscription inscription =
                                  snapshotInscription.data![index];
                              return ListTile(
                                leading: Text(
                                  inscription.fullName ?? 'اسم غير متاح',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("لا يوجد مترشحون"),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("خطأ في جلب البيانات"),
              );
            }
          },
        ),
      ),
    );
  }
}
