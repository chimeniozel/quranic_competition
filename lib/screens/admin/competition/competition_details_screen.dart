import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/screens/admin/competition/add_competition_screen.dart';
import 'package:quranic_competition/screens/admin/competition/competition_jurys.dart';
import 'package:quranic_competition/screens/admin/competition/competition_result.dart';
import 'package:quranic_competition/screens/admin/competition/jury_results_files.dart';
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
  bool isloading = false;
  String query = "";
  @override
  Widget build(BuildContext context) {
    Competition competition = widget.competition;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        toolbarHeight: 60,
        title: Text(
          competition.competitionVirsion.toString(),
          style: const TextStyle(
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
                  builder: (context) => CompetitionJurys(
                    competition: widget.competition,
                  ),
                ),
              );
            },
            child: const Column(
              children: [
                Icon(
                  Iconsax.profile_2user,
                  color: AppColors.whiteColor,
                ),
                Text(
                  "لجنة التحكيم",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JuryResultsFiles(
                    competition: widget.competition,
                  ),
                ),
              );
            },
            child: const Column(
              children: [
                Icon(
                  Iconsax.trend_up,
                  color: AppColors.whiteColor,
                ),
                Text(
                  "تصحيح اللجنة",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: AppColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
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
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                floatingLabelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
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
              height: 10.0,
            ),
            if (selectedType != null)
              Expanded(
                child: StreamBuilder<List<Inscription>>(
                  stream: InscriptionService.fetchContestantsStream(
                      competition: competition,
                      competitionType: selectedType!,
                      query: query),
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
                              if (competition.isActive!) {
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
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
                                                  BorderRadius.circular(10.0),
                                            )),
                                        onPressed: () async {
                                          await InscriptionService
                                                  .deleteInscription(
                                                      inscription: inscription,
                                                      inscriptionType:
                                                          selectedType!,
                                                      version: widget
                                                          .competition
                                                          .competitionVirsion!)
                                              .whenComplete(() {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    "تم حذف المتسابق بنجاح!"),
                                                action: SnackBarAction(
                                                  label: 'إخفاء',
                                                  onPressed: () {},
                                                ),
                                                backgroundColor:
                                                    AppColors.greenColor,
                                              ),
                                            );
                                            setState(() {
                                              // Refresh the list
                                            });
                                          }).catchError((error) {
                                            final failureSnackBar = SnackBar(
                                              content: const Text(
                                                  "حدث خطأ أثناء حذف المتسابق!"),
                                              action: SnackBarAction(
                                                label: 'تراجع',
                                                onPressed: () {},
                                              ),
                                              backgroundColor:
                                                  AppColors.pinkColor,
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(failureSnackBar);
                                          });
                                          Navigator.pop(context);
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
                              } else {
                                final failureSnackBar = SnackBar(
                                  content: const Text(
                                      "لا يمكن حذف المتسابق لأن المسابقة غير نشطة !"),
                                  action: SnackBarAction(
                                    label: 'تراجع',
                                    onPressed: () {},
                                  ),
                                  backgroundColor: AppColors.yellowColor,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(failureSnackBar);
                              }
                            },
                            child: Container(
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
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Row(
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
                                            Text(
                                              "${inscription.phoneNumber}",
                                              textDirection: TextDirection.ltr,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      minimumSize: const Size(double.infinity, 50.0),
                    ),
                    onPressed: () {
                      // Navigate to the results screen
                      if (widget.competition.firstRoundIsPublished! == true ||
                          widget.competition.isActive! == false) {
                        final failureSnackBar = SnackBar(
                          content: const Text(
                              "لا يمكنك التعديل على النسخة بعد نشر النتائج الأولية"),
                          action: SnackBarAction(
                            label: 'تراجع',
                            onPressed: () {},
                          ),
                          backgroundColor: AppColors.pinkColor,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(failureSnackBar);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddCompetitionScreen(
                              competition: competition,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Column(
                      children: [
                        Icon(
                          Iconsax.edit,
                          color: AppColors.whiteColor,
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          "تعديل الإعدادات",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(10.0),
                      minimumSize: const Size(double.infinity, 50.0),
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
                    child: Column(
                      children: [
                        const Icon(
                          Iconsax.trend_up,
                          color: AppColors.whiteColor,
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        Text(
                          competition.isActive!
                              ? "نشر نتائج المسابقة"
                              : "نتائج المسابقة",
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grayColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
                  ),
                  onPressed: () async {
                    setState(() {
                      isloading = true;
                    });
                    await InscriptionService.fetchContestants(
                      competition: competition,
                      competitionType: selectedType!,
                      query: query,
                    ).then((inscriptions) {
                      if (inscriptions.isNotEmpty) {
                        InscriptionService.exportInscriptionsAsXlsx(
                            inscriptions, competition, selectedType!, context);
                      } else {
                        final failureSnackBar = SnackBar(
                          content: const Text("لا يوجد مترشحون"),
                          action: SnackBarAction(
                            label: 'تراجع',
                            onPressed: () {},
                          ),
                          backgroundColor: AppColors.yellowColor,
                        );
                        ScaffoldMessenger.of(context)
                            .showSnackBar(failureSnackBar);
                      }
                    });
                    setState(() {
                      isloading = false;
                    });
                  },
                  child: const Column(
                    children: [
                      Icon(
                        Iconsax.export_1,
                        color: AppColors.whiteColor,
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        "استخراج",
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.whiteColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
