import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/jury/detail_contestant_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class JuryFinalResults extends StatefulWidget {
  const JuryFinalResults({super.key});

  @override
  State<JuryFinalResults> createState() => _JuryFinalResultsState();
}

class _JuryFinalResultsState extends State<JuryFinalResults> {
  String? selectedType = "adult_inscription";
  @override
  Widget build(BuildContext context) {
    CompetitionProvider competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('النتائج النهائية'),
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
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: selectedType == "adult_inscription"
                                    ? AppColors.primaryColor
                                    : AppColors.blackColor.withOpacity(.1),
                                width: 1,
                              ),
                            ),
                            backgroundColor: selectedType == "adult_inscription"
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
                              color: selectedType == "adult_inscription"
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
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: selectedType == "child_inscription"
                                    ? AppColors.primaryColor
                                    : AppColors.blackColor.withOpacity(.1),
                                width: 1,
                              ),
                            ),
                            backgroundColor: selectedType == "child_inscription"
                                ? AppColors.primaryColor
                                : AppColors.whiteColor,
                            minimumSize: const Size(double.infinity, 50.0),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = "child_inscription";
                            });
                          },
                          child: Text(
                            "المتسابقين الصغار",
                            style: TextStyle(
                              color: selectedType == "child_inscription"
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
                    child: StreamBuilder<List<Inscription>>(
                      stream: InscriptionService.streamContestants(
                          competitionProvider.competition!.competitionVirsion
                              .toString(),
                          selectedType.toString(),
                          "التصفيات النهائية"),
                      builder: (context, snapshot) {
                        NoteResult? cheickh;
                        if (snapshot.hasError) {
                          return Text(
                              "حدث خطأ أثناء جلب البيانات: ${snapshot.error}");
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("لا توجد بيانات"),
                          );
                        }

                        List<Inscription> inscriptions = snapshot.data!;
                        return ListView.separated(
                          scrollDirection: Axis.vertical,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 15.0,
                          ),
                          itemCount: inscriptions.length,
                          itemBuilder: (context, index) {
                            Inscription inscription = inscriptions[index];
                            NoteResult? noteResult;
                            bool isAdult = DateTime.now().year -
                                    inscription.birthDate!.year >=
                                13;
                            inscription.tashihMachaikhs?.finalRound
                                ?.forEach((result) {
                              if (isAdult) {
                                noteResult = NoteResult.fromMapAdult(result);
                                if (noteResult!.cheikhName ==
                                    authProvider.currentUser!.fullName) {
                                  cheickh = NoteResult.fromMapAdult(result);
                                }
                              } else {
                                noteResult = NoteResult.fromMapChild(result);
                                if (noteResult!.cheikhName ==
                                    authProvider.currentUser!.fullName) {
                                  cheickh = NoteResult.fromMapChild(result);
                                }
                              }
                            });

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailContestantScreen(
                                      inscription: inscription,
                                      noteResult: cheickh,
                                      competitionType: selectedType.toString(),
                                      competitionVersion: competitionProvider
                                          .competition!.competitionVirsion
                                          .toString(),
                                      competitionRound: "التصفيات النهائية",
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    padding: const EdgeInsets.all(8.0),
                                    width: MediaQuery.of(context).size.width,
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
                                              offset: const Offset(0, 1))
                                        ]),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            "المتسابق رقم : ${inscription.idInscription}"),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Divider(
                                          color: AppColors.blackColor
                                              .withOpacity(.2),
                                          height: 1,
                                          indent: 50,
                                          endIndent: 50,
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    const Text("التجويد"),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Text(
                                                      cheickh!.notes!.noteTajwid
                                                          .toString(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Center(
                                                child: Column(
                                                  children: [
                                                    const Text("حسن الصوت"),
                                                    const SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Text(
                                                      cheickh!
                                                          .notes!.noteHousnSawtt
                                                          .toString(),
                                                    ),
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
                                                        height: 5.0,
                                                      ),
                                                      Text(
                                                          "${cheickh!.notes!.noteIltizamRiwaya}"),
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
                                                      const Text("عذوبة الصوت"),
                                                      const SizedBox(
                                                        height: 5.0,
                                                      ),
                                                      Text(cheickh!.notes!
                                                          .noteOu4oubetSawtt!
                                                          .toString()),
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
                                                        height: 5.0,
                                                      ),
                                                      Text(cheickh!.notes!
                                                          .noteWaqfAndIbtidaa
                                                          .toString()),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isAdult && cheickh!.isCorrected!)
                                    const Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          Text(
                                            "تم التصحيح",
                                            style: TextStyle(
                                              color: AppColors.greenColor,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Icon(
                                            Iconsax.verify5,
                                            color: AppColors.greenColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (!isAdult && cheickh!.isCorrected!)
                                    const Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          Text(
                                            "تم التصحيح",
                                            style: TextStyle(
                                              color: AppColors.greenColor,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Icon(
                                            Iconsax.verify5,
                                            color: AppColors.greenColor,
                                          ),
                                        ],
                                      ),
                                    ),
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
      bottomNavigationBar: competitionProvider.competition == null
          ? null
          : Padding(
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
                      competitionProvider.competition!.competitionVirsion
                          .toString(),
                      selectedType.toString(),
                      authProvider.currentUser!.fullName,
                      "التصفيات النهائية");
                  bool isNoted = returnData["isNoted"];
                  List<Inscription> notedInscriptions =
                      returnData["notedInscriptions"];
                  List<Map<String, dynamic>> dataList = returnData["dataList"];
                  if (isNoted && dataList.isNotEmpty) {
                    // Send notes to the admin
                    InscriptionService.exportDataAsXlsx(
                        notedInscriptions,
                        dataList,
                        authProvider.currentUser!.fullName,
                        competitionProvider.competition!,
                        selectedType.toString(),
                        context,
                        "التصفيات النهائية");
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
                    ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
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
    );
  }
}
