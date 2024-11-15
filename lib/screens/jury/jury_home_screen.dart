import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/jury/detail_contestant_screen.dart';
import 'package:quranic_competition/screens/jury/jury_final_results.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class JuryHomeScreen extends StatefulWidget {
  final String? selectedType;
  const JuryHomeScreen({super.key, this.selectedType});

  @override
  State<JuryHomeScreen> createState() => _JuryHomeScreenState();
}

class _JuryHomeScreenState extends State<JuryHomeScreen> {
  String? selectedType;

  @override
  void initState() {
    if (widget.selectedType != null) {
      selectedType = widget.selectedType;
    } else {
      selectedType = "adult_inscription";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CompetitionProvider? competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);

    return Consumer<AuthProviders>(
      builder: (context, authProviders, child) {
        if (competitionProvider.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (competitionProvider.competition == null) {
          return const Scaffold(
              body: Center(child: Text('No active competition')));
        }
        return authProviders.currentJury != null
            ? Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  title: const Text("التصفيات الأولى"),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: "تسجيل الخروج",
                    icon: const Icon(
                      Iconsax.logout,
                      color: AppColors.pinkColor,
                    ),
                    onPressed: () {
                      authProviders.logout(context);
                    },
                  ),
                  actions:
                      !competitionProvider.competition!.firstRoundIsPublished!
                          ? null
                          : [
                              IconButton(
                                onPressed: () {
                                  // Navigate to the JuryFinalResults screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const JuryFinalResults(),
                                    ),
                                  );
                                },
                                icon: const Row(
                                  children: [
                                    Text(
                                      "النتائج النهائية",
                                      style: TextStyle(
                                        color: AppColors.blackColor,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Icon(
                                      IconlyLight.arrow_left_square,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: competitionProvider.competition == null
                      ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Center(
                            child: Text("لا توجد مسابقة نشطة الآن"),
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                          color: selectedType ==
                                                  "adult_inscription"
                                              ? AppColors.primaryColor
                                              : AppColors.blackColor
                                                  .withOpacity(.1),
                                          width: 1,
                                        ),
                                      ),
                                      backgroundColor:
                                          selectedType == "adult_inscription"
                                              ? AppColors.primaryColor
                                              : AppColors.whiteColor,
                                      minimumSize: const Size(
                                        double.infinity,
                                        50.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedType = "adult_inscription";
                                      });
                                    },
                                    child: Text(
                                      "المتسابقين الكبار",
                                      style: TextStyle(
                                        color:
                                            selectedType == "adult_inscription"
                                                ? AppColors.whiteColor
                                                : AppColors.blackColor,
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: BorderSide(
                                          color: selectedType ==
                                                  "child_inscription"
                                              ? AppColors.primaryColor
                                              : AppColors.blackColor
                                                  .withOpacity(.1),
                                          width: 1,
                                        ),
                                      ),
                                      backgroundColor:
                                          selectedType == "child_inscription"
                                              ? AppColors.primaryColor
                                              : AppColors.whiteColor,
                                      minimumSize:
                                          const Size(double.infinity, 50.0),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedType = "child_inscription";
                                      });
                                    },
                                    child: Text(
                                      "المتسابقين الصغار",
                                      style: TextStyle(
                                        color:
                                            selectedType == "child_inscription"
                                                ? AppColors.whiteColor
                                                : AppColors.blackColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Flexible(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: InscriptionService.streamContestants(
                                  version: competitionProvider
                                      .competition!.competitionVirsion
                                      .toString(),
                                  competitionType: selectedType.toString(),
                                  competitionRound: "التصفيات الأولى",
                                  jury: authProviders.currentJury!,
                                  successMoyenne: competitionProvider
                                      .competition!.successMoyenne!,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        "حدث خطأ أثناء جلب البيانات: ${snapshot.error}");
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text("لا توجد بيانات"));
                                  }

                                  // List<Map<String, dynamic>> inscriptions = [];
                                  // for (var item in snapshot.data!) {
                                  //   // Inscription inscription =
                                  //   //     item["inscription"];
                                  //   NoteModel? firstNotes =
                                  //       item["firstNotes"] as NoteModel?;
                                  //   if (firstNotes != null &&
                                  //       !firstNotes.isCorrected!) {
                                  //     inscriptions.add(item);
                                  //   }
                                  // }

                                  return ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 15.0),
                                    itemCount:
                                        // inscriptions.isEmpty
                                        //     ?
                                        snapshot.data!.length,
                                    // : inscriptions.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> map =
                                          // inscriptions.isEmpty
                                          //     ?
                                          snapshot.data![index];
                                      // : inscriptions[index];
                                      Inscription inscription =
                                          map["inscription"];
                                      JuryInscription? juryInscription =
                                          map["juryInscription"] as JuryInscription?;

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailContestantScreen(
                                                inscription: inscription,
                                                firsNoteModel: juryInscription?.firstNotes,
                                                lastNoteModel: juryInscription?.lastNotes,
                                                competitionType:
                                                    selectedType.toString(),
                                                competitionVersion:
                                                    competitionProvider
                                                        .competition!
                                                        .competitionVirsion
                                                        .toString(),
                                                competitionRound:
                                                    "التصفيات الأولى",
                                              ),
                                            ),
                                          );
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color: AppColors.whiteColor,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.blackColor
                                                        .withOpacity(.3),
                                                    blurRadius: 1.0,
                                                    spreadRadius: 2.0,
                                                    blurStyle: BlurStyle.outer,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "المتسابق رقم : ${inscription.idInscription} "),
                                                  const SizedBox(height: 10.0),
                                                  Divider(
                                                      color: AppColors
                                                          .blackColor
                                                          .withOpacity(.2),
                                                      height: 1,
                                                      indent: 50,
                                                      endIndent: 50),
                                                  const SizedBox(height: 10.0),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                  "التجويد"),
                                                              const SizedBox(
                                                                  height: 5.0),
                                                              Text(juryInscription?.firstNotes
                                                                      ?.noteTajwid
                                                                      ?.toString() ??
                                                                  "0.0"),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Center(
                                                          child: Column(
                                                            children: [
                                                              const Text(
                                                                  "حسن الصوت"),
                                                              const SizedBox(
                                                                  height: 5.0),
                                                              Text(juryInscription?.firstNotes
                                                                      ?.noteHousnSawtt
                                                                      ?.toString() ??
                                                                  "0.0"),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (selectedType ==
                                                          "adult_inscription")
                                                        Expanded(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const Text(
                                                                    "الإلتزام بالرواية"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(juryInscription?.firstNotes
                                                                        ?.noteIltizamRiwaya
                                                                        ?.toString() ??
                                                                    "0.0"),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (selectedType ==
                                                          "child_inscription")
                                                        Expanded(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const Text(
                                                                    "عذوبة الصوت"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(juryInscription?.firstNotes
                                                                        ?.noteOu4oubetSawtt
                                                                        ?.toString() ??
                                                                    "0.0"),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      if (selectedType ==
                                                          "child_inscription")
                                                        Expanded(
                                                          child: Center(
                                                            child: Column(
                                                              children: [
                                                                const Text(
                                                                    "الوقف والإبتداء"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(juryInscription?.firstNotes
                                                                        ?.noteWaqfAndIbtidaa
                                                                        ?.toString() ??
                                                                    "0.0"),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // if (isAdult &&
                                            //     firstNotes?.isCorrected == true)
                                            //   const Positioned(
                                            //     top: 10,
                                            //     right: 10,
                                            //     child: Row(
                                            //       children: [
                                            //         Text("تم التصحيح",
                                            //             style: TextStyle(
                                            //                 color: AppColors
                                            //                     .greenColor)),
                                            //         SizedBox(width: 5.0),
                                            //         Icon(Iconsax.verify5,
                                            //             color: AppColors
                                            //                 .greenColor),
                                            //       ],
                                            //     ),
                                            //   ),
                                            // if (!isAdult &&
                                            //     firstNotes?.isCorrected == true)
                                            //   const Positioned(
                                            //     top: 10,
                                            //     right: 10,
                                            //     child: Row(
                                            //       children: [
                                            //         Text("تم التصحيح",
                                            //             style: TextStyle(
                                            //                 color: AppColors
                                            //                     .greenColor)),
                                            //         SizedBox(width: 5.0),
                                            //         Icon(Iconsax.verify5,
                                            //             color: AppColors
                                            //                 .greenColor),
                                            //       ],
                                            //     ),
                                            //   ),
                                          ],
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
                bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      var returnData = await AuthService.checkAllNotes(
                        cometionType: selectedType.toString(),
                        competitionRound: "التصفيات الأولى",
                        version: competitionProvider
                            .competition!.competitionVirsion
                            .toString(),
                        userID: authProviders.currentJury!.userID!,
                      );
                      bool isNoted = returnData["isNoted"];
                      List<Inscription> notedInscriptions =
                          returnData["notedInscriptions"];
                      List<Map<String, dynamic>> dataList =
                          returnData["dataList"];
                      if (isNoted && dataList.isNotEmpty) {
                        // Send notes to the admin
                        InscriptionService.exportDataAsXlsx(
                            notedInscriptions,
                            dataList,
                            authProviders.currentJury!.fullName!,
                            competitionProvider.competition!,
                            selectedType.toString(),
                            context,
                            "التصفيات الأولى");
                      } else {
                        // Snackbar for failure
                        final successSnackBar = SnackBar(
                          content: const Text('لم يتم التصحيح لكل المتسابقين'),
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
                    child: const Text(
                      "إرسال إلى الإدارة",
                      style: TextStyle(
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              )
            : const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
      },
    );
  }
}
