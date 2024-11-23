import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/competition/add_competition_screen.dart';
import 'package:quranic_competition/screens/admin/competition/competition_details_screen.dart';

class CompetitionManagementScreen extends StatefulWidget {
  const CompetitionManagementScreen({super.key});

  @override
  State<CompetitionManagementScreen> createState() =>
      _CompetitionManagementScreenState();
}

class _CompetitionManagementScreenState
    extends State<CompetitionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviders>(builder: (context, authProviders, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('النسخ السابقة'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('competitions')
                      .orderBy("isActive", descending: true)
                      .orderBy("startDate", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
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

                        return GestureDetector(
                          onLongPress: () {
                            // Show confirmation dialog to delete the competition
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'تحذير: حذف المسابقة',
                                  style: TextStyle(
                                      color: Colors
                                          .red), // Change title color to red
                                ),
                                content: const Text(
                                  'هل أنت متأكد أنك تريد حذف هذه المسابقة؟ هذا الإجراء لا يمكن التراجع عنه.',
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
                                              BorderRadius.circular(10.0),
                                        )),
                                    onPressed: () {
                                      if (!competition.isActive!) {
                                        // Delete the competition from Firestore
                                        FirebaseFirestore.instance
                                            .collection('inscriptions')
                                            .doc(competition.competitionVirsion)
                                            .delete()
                                            .whenComplete(() async {
                                          var docAdult = await FirebaseFirestore
                                              .instance
                                              .collection('counters')
                                              .doc(
                                                  "${competition.competitionVirsion}-adult_inscription")
                                              .get();
                                          var docChild = await FirebaseFirestore
                                              .instance
                                              .collection('counters')
                                              .doc(
                                                  "${competition.competitionVirsion}-child_inscription")
                                              .get();
                                          if (docAdult.exists) {
                                            FirebaseFirestore.instance
                                                .collection('counters')
                                                .doc(
                                                    "${competition.competitionVirsion}-adult_inscription")
                                                .delete();
                                          }
                                          if (docChild.exists) {
                                            FirebaseFirestore.instance
                                                .collection('counters')
                                                .doc(
                                                    "${competition.competitionVirsion}-child_inscription")
                                                .delete();
                                          }
                                          FirebaseFirestore.instance
                                              .collection('competitions')
                                              .doc(competitionId)
                                              .delete()
                                              .then((_) {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'تم حذف المسابقة بنجاح'),
                                                backgroundColor:
                                                    AppColors.greenColor,
                                              ),
                                            );
                                          }).catchError((error) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'خطأ في الحذف: $error'),
                                                backgroundColor:
                                                    AppColors.grayColor,
                                              ),
                                            );
                                          });
                                        });
                                      } else {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        // Show error message if competition is not active
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'لا يمكنك حذف هذه المسابقة حتى تنتهي الفترة المعلقة.',
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
                            );
                          },
                          onTap: () {
                            // Navigation to Competition Details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompetitionDetailsScreen(
                                  competition: competition,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                              right: 8.0,
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
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        competition.competitionVirsion
                                            .toString(),
                                      ),
                                    ),
                                    competition.isActive!
                                        ? Container(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.pinkColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                              ),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('competitions')
                                                    .doc(competitionId)
                                                    .update({
                                                  'isActive': false,
                                                }).then((_) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'تم إنهاء المسابقة بنجاح'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                });
                                              },
                                              child: const Text(
                                                'إنهاء المسابقة',
                                                style: TextStyle(
                                                  color: AppColors.whiteColor,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 60.0,
                                          ),
                                  ],
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            // Navigate to the add competition screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCompetitionScreen(),
              ),
            );
          },
          child: const Icon(
            Iconsax.add,
            color: AppColors.whiteColor,
          ),
        ),
      );
    });
  }
}
