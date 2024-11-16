import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/screens/admin/competition_management/competion_archive.dart';
import '../constants/colors.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ السابقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('competitions')
                    .orderBy("isActive", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  var competitions = snapshot.data!.docs;

                  if (competitions.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مسابقات حالياً'),
                    );
                  }

                  return ListView.builder(
                    itemCount: competitions.length,
                    itemBuilder: (context, index) {
                      Competition competition = Competition.fromMap(
                          competitions[index].data() as Map<String, dynamic>);
                      var competitionId = competitions[index].id;
                      var startDate = competition.startDate;
                      // var endDate = competition.endDate;

                      // Check if the competition end date has passed
                      // if (endDate != null && DateTime.now().isAfter(endDate)) {
                      //   // Update the competition to be inactive if endDate has passed
                      //   FirebaseFirestore.instance
                      //       .collection('competitions')
                      //       .doc(competitionId)
                      //       .update({'isActive': false});
                      //   competition.setActive = false;
                      // }

                      return GestureDetector(
                        onTap: () {
                          // Navigation to Competition Details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompetionArchive(
                                competition: competition,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.only(
                            right: 8.0,
                          ),
                          height: 60.0,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                    competition.competitionVirsion.toString()),
                              ),
                              // Expanded(
                              //   child: Text(
                              //     '${Utils.arDateFormat(startDate!)} - ${Utils.arDateFormat(endDate!)}',
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
