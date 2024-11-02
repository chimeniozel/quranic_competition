import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/competition_management/about_us/about_us_screen.dart';
import 'package:quranic_competition/screens/admin/competition_management/competition_jurys.dart';
import 'package:quranic_competition/screens/admin/competition_management/competition_details_screen.dart';
import 'package:quranic_competition/screens/admin/competition_management/quranic_benefit_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class CompetitionManagement extends StatefulWidget {
  const CompetitionManagement({super.key});

  @override
  State<CompetitionManagement> createState() => _CompetitionManagementState();
}

class _CompetitionManagementState extends State<CompetitionManagement> {
  TextEditingController competitionVirsionController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now().add(const Duration(days: 1));

  // Date picker for start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendar,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: child!,
        );
      },
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });
    }
  }

  // Date picker for end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendar,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: child!,
        );
      },
      initialDate: selectedStartDate.add(const Duration(days: 1)),
      firstDate: selectedStartDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedEndDate = pickedDate;
      });
    }
  }

  Future<void> _saveCompetition() async {
    String competitionVersion = competitionVirsionController.text.trim();

    if (competitionVersion.isNotEmpty) {
      bool hasActiveCompetition =
          await CompetitionService.hasActiveCompetition();

      if (hasActiveCompetition) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('لا يمكن إنشاء نسخة جديدة أثناء وجود نسخة نشطة حالياً'),
            backgroundColor: AppColors.yellowColor,
          ),
        );
        return;
      }

      bool isActive = DateTime.now().isAfter(selectedStartDate) &&
          DateTime.now().isBefore(selectedEndDate);

      Competition competition = Competition(
        competitionVirsion: competitionVersion,
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        isActive: isActive,
        competitionTypes: ["child_inscription", "adult_inscription"],
        archiveEntry: ArchiveEntry(
            title: "", description: "", imagesURL: [], videosURL: []),
      );

      await FirebaseFirestore.instance
          .collection('competitions')
          .add(competition.toMap())
          .then((value) async {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(value.id)
            .update({
          'competitionId': value.id,
        });
      });

      competitionVirsionController.clear();
      setState(() {
        selectedStartDate = DateTime.now();
        selectedEndDate = DateTime.now().add(const Duration(days: 1));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('إدارة المسابقة'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout),
            onPressed: () {
              AuthService.logoutUser(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              padding: const EdgeInsets.all(5.0),
              child: Image.asset('assets/images/logos/logo.png'),
            ),
            ListTile(
              leading: const Icon(Iconsax.tag_user),
              title: const Text("أعضاء لجنة التحكيم"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompetitionJurys(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: const Text("من نحن"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: const Text("الفوائد القرآنية"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuranicBenefitScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('قم بإضافة نسخة جديد'),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("اسم النسخة"),
                      const SizedBox(
                        height: 5,
                      ),
                      InputWidget(
                        label: "",
                        controller: competitionVirsionController,
                        hint: "اسم النسخة",
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Column(
                    children: [
                      const Text("تاريخ البداية"),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: AppColors.whiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.black.withOpacity(.3),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 13.0),
                        ),
                        onPressed: () => _selectStartDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Iconsax.calendar),
                            // const SizedBox(width: 10.0),
                            Text(
                              DateFormat('d/M/y').format(selectedStartDate),
                              style:
                                  const TextStyle(color: AppColors.blackColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: Column(
                    children: [
                      const Text("تاريخ النهاية"),
                      const SizedBox(
                        height: 5,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: AppColors.whiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.black.withOpacity(.3),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 13.0),
                        ),
                        onPressed: () => _selectEndDate(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Iconsax.calendar),
                            // const SizedBox(width: 10.0),
                            Text(
                              DateFormat('d/M/y').format(selectedEndDate),
                              style:
                                  const TextStyle(color: AppColors.blackColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: const Size(double.infinity, 45.0),
              ),
              onPressed: _saveCompetition,
              child: const Text(
                'حفظ',
                style: TextStyle(color: AppColors.whiteColor),
              ),
            ),
            const SizedBox(height: 10.0),
            const Text('المسابقات الحالية'),
            const SizedBox(height: 10.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('competitions')
                    .orderBy("isActive", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var competitions = snapshot.data!.docs;

                  if (competitions.isEmpty) {
                    return const Center(child: Text('لا توجد مسابقات حالياً'));
                  }

                  return ListView.builder(
                    itemCount: competitions.length,
                    itemBuilder: (context, index) {
                      Competition competition = Competition.fromMap(
                          competitions[index].data() as Map<String, dynamic>);
                      var competitionId = competitions[index].id;
                      var startDate = competition.startDate;
                      var endDate = competition.endDate;

                      // Check if the competition end date has passed
                      if (endDate != null && DateTime.now().isAfter(endDate)) {
                        // Update the competition to be inactive if endDate has passed
                        FirebaseFirestore.instance
                            .collection('competitions')
                            .doc(competitionId)
                            .update({'isActive': false});
                        competition.setActive = false;
                      }

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
                                          .collection('competitions')
                                          .doc(competitionId)
                                          .delete()
                                          .then((_) {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('تم حذف المسابقة بنجاح'),
                                            backgroundColor:
                                                AppColors.greenColor,
                                          ),
                                        );
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('خطأ في الحذف: $error'),
                                            backgroundColor:
                                                AppColors.grayColor,
                                          ),
                                        );
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
                                    child: Text(competition.competitionVirsion
                                        .toString()),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${Utils.arDateFormat(startDate!)} - ${Utils.arDateFormat(endDate!)}',
                                    ),
                                  ),
                                  competition.isActive!
                                      ? Container(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                            ),
                                            onPressed: () {
                                              CompetitionService
                                                  .extendCompetition(context,
                                                      competitionId, endDate);
                                            },
                                            child: const Text(
                                              'تمديد',
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
    );
  }
}
