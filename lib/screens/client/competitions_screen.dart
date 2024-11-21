import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/screens/admin/archives/competion_archive.dart';
import '../../constants/colors.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
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
