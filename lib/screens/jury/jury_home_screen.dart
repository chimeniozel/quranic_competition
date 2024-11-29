import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/note_model.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/jury/detail_contestant_screen.dart';
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

  String query = "";

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
              body: Center(
                  child: Column(
            children: [
              Text("جاري تحميل بيانات المسبقة"),
              CircularProgressIndicator(),
            ],
          )));
        }

        if (competitionProvider.competition == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              title: IconButton(
                tooltip: "تسجيل الخروج",
                icon: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "قم بتسجيل الخروج",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Iconsax.logout,
                      color: AppColors.whiteColor,
                    ),
                  ],
                ),
                onPressed: () {
                  authProviders.logout(context);
                },
              ),
            ),
            body: const Center(
              child: Text('لا توجد نسخة نشطة حاليا !'),
            ),
          );
        }
        if (competitionProvider.competition!.lastRoundIsPublished!) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              title: IconButton(
                tooltip: "تسجيل الخروج",
                icon: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "قم بتسجيل الخروج",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Icon(
                      Iconsax.logout,
                      color: AppColors.whiteColor,
                    ),
                  ],
                ),
                onPressed: () {
                  authProviders.logout(context);
                },
              ),
            ),
            body: const Center(
              child: Text('تم نشر التصحيح لم يعد بإمكانك الدخول'),
            ),
          );
        }
        return authProviders.currentJury != null &&
                authProviders.currentJury!.competitions!.contains(
                    competitionProvider.competition!.competitionVirsion)
            ? Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.primaryColor,
                  title: Text(
                    competitionProvider.competition!.firstRoundIsPublished!
                        ? "النتائج النهائية"
                        : "التصفيات الأولى",
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: "تسجيل الخروج",
                    icon: const Icon(
                      Iconsax.logout,
                      color: AppColors.whiteColor,
                    ),
                    onPressed: () {
                      authProviders.logout(context);
                    },
                  ),
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
                            if (selectedType != null)
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
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade200, width: 2),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.black, width: 1.5),
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
                            Expanded(
                              child: StreamBuilder<List<Map<String, dynamic>>>(
                                stream: InscriptionService.streamContestants(
                                  version: competitionProvider
                                      .competition!.competitionVirsion
                                      .toString(),
                                  competitionType: selectedType.toString(),
                                  competitionRound: competitionProvider
                                          .competition!.firstRoundIsPublished!
                                      ? "التصفيات النهائية"
                                      : "التصفيات الأولى",
                                  jury: authProviders.currentJury!,
                                  successMoyenneChild: competitionProvider
                                      .competition!.successMoyenneChild!,
                                  successMoyenneAdult: competitionProvider
                                      .competition!.successMoyenneAdult!,
                                  query: query,
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

                                  if (snapshot.data == null ||
                                      snapshot.data!.isEmpty) {
                                    return const Center(
                                        child: Text("لا توجد بيانات"));
                                  }

                                  // Determine the correction field based on the round
                                  bool isFinalRound = competitionProvider
                                      .competition!.firstRoundIsPublished!;
                                  String correctionField = isFinalRound
                                      ? 'isLastCorrected'
                                      : 'isFirstCorrected';

                                  // Filter the data
                                  List<Map<String, dynamic>> correctedList =
                                      snapshot.data!;
                                  List<Map<String, dynamic>> notCorrectedList =
                                      correctedList.where((map) {
                                    JuryInscription? juryInscription =
                                        map["juryInscription"]
                                            as JuryInscription?;
                                    if (juryInscription != null) {
                                      // Return true for those not corrected
                                      return juryInscription.isFirstCorrected ==
                                          false;
                                    } else {
                                      return true;
                                    }
                                  }).toList();

                                  if (notCorrectedList.isEmpty) {
                                    notCorrectedList = correctedList;
                                  }

                                  // Use the filtered list if not all are corrected
                                  List<Map<String, dynamic>> displayList =
                                      notCorrectedList.isNotEmpty
                                          ? notCorrectedList
                                          : correctedList;

                                  return ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 15.0),
                                    itemCount: displayList.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> map =
                                          displayList[index];
                                      Inscription inscription =
                                          map["inscription"];
                                      JuryInscription? juryInscription =
                                          map["juryInscription"]
                                              as JuryInscription?;
                                      NoteModel? noteModel = isFinalRound
                                          ? juryInscription?.lastNotes!
                                          : juryInscription?.firstNotes!;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailContestantScreen(
                                                inscription: inscription,
                                                noteModel: noteModel,
                                                competitionType:
                                                    selectedType.toString(),
                                                competitionVersion:
                                                    competitionProvider
                                                        .competition!
                                                        .competitionVirsion
                                                        .toString(),
                                                competitionRound: isFinalRound
                                                    ? "التصفيات النهائية"
                                                    : "التصفيات الأولى",
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
                                                              Text(noteModel
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
                                                              Text(noteModel
                                                                      ?.noteHousnSawtt
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
                                                                    "الإلتزام بالرواية"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(noteModel
                                                                        ?.noteIltizamRiwaya
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
                                                                    "عذوبة الصوت"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(noteModel
                                                                        ?.noteOu4oubetSawtt
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
                                                                    "الوقف والإبتداء"),
                                                                const SizedBox(
                                                                    height:
                                                                        5.0),
                                                                Text(noteModel
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
                                            if (juryInscription != null &&
                                                juryInscription.isAdult! &&
                                                juryInscription.toMapAdult()[
                                                        correctionField] ==
                                                    true)
                                              const Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Row(
                                                  children: [
                                                    Text("تم التصحيح",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .greenColor)),
                                                    SizedBox(width: 5.0),
                                                    Icon(Iconsax.verify5,
                                                        color: AppColors
                                                            .greenColor),
                                                  ],
                                                ),
                                              ),
                                            if (juryInscription != null &&
                                                !juryInscription.isAdult! &&
                                                juryInscription.toMapChild()[
                                                        correctionField] ==
                                                    true)
                                              const Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Row(
                                                  children: [
                                                    Text("تم التصحيح",
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .greenColor)),
                                                    SizedBox(width: 5.0),
                                                    Icon(Iconsax.verify5,
                                                        color: AppColors
                                                            .greenColor),
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
                        competitionRound: competitionProvider
                                .competition!.firstRoundIsPublished!
                            ? "التصفيات النهائية"
                            : "التصفيات الأولى",
                        version: competitionProvider
                            .competition!.competitionVirsion
                            .toString(),
                        userID: authProviders.currentJury!.userID!,
                      );
                      bool isNoted = returnData["isNoted"];
                      List<Inscription> notedInscriptions =
                          returnData["notedInscriptions"];
                      List<JuryInscription> dataList = returnData["dataList"];
                      if (isNoted && dataList.isNotEmpty) {
                        // Send notes to the admin
                        InscriptionService.exportJuryDataAsXlsx(
                            notedInscriptions,
                            dataList,
                            authProviders.currentJury!,
                            competitionProvider.competition!,
                            selectedType.toString(),
                            context,
                            competitionProvider
                                    .competition!.firstRoundIsPublished!
                                ? "التصفيات النهائية"
                                : "التصفيات الأولى");
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
            : Scaffold(
                appBar: AppBar(
                  backgroundColor: AppColors.primaryColor,
                  title: IconButton(
                    tooltip: "تسجيل الخروج",
                    icon: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "قم بتسجيل الخروج",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.whiteColor,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Iconsax.logout,
                          color: AppColors.whiteColor,
                        ),
                      ],
                    ),
                    onPressed: () {
                      authProviders.logout(context);
                    },
                  ),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("أنت لست مشرفا في النسخة الحالية"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "قم بتسجيل الخروج ثم أعد تسجيل الدخول",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
