import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/jury/detail_contestant_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';
import 'package:quranic_competition/widgets/custtom_button.dart';

class JuryHomeScreen extends StatefulWidget {
  const JuryHomeScreen({super.key});

  @override
  State<JuryHomeScreen> createState() => _JuryHomeScreenState();
}

class _JuryHomeScreenState extends State<JuryHomeScreen> {
  String? selectedType = "adult_inscription";
  CompetitionProvider? competitionProvider;

  @override
  void initState() {
    super.initState();

    // Delay context usage until the widget is fully built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      competitionProvider =
          Provider.of<CompetitionProvider>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("لجنة التحكيم"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CusttomButton(
                      text: "المتسابقين الكبار",
                      backgroundColor: selectedType == "adult_inscription"
                          ? AppColors.primaryColor
                          : AppColors.whiteColor,
                      minimumSize: const Size(double.infinity, 70.0),
                      borderSide: BorderSide(
                        color: selectedType == "adult_inscription"
                            ? AppColors.primaryColor
                            : AppColors.blackColor.withOpacity(.1),
                        width: 1,
                      ),
                      textStyle: TextStyle(
                        color: selectedType == "adult_inscription"
                            ? AppColors.whiteColor
                            : AppColors.blackColor,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedType = "adult_inscription";
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: CusttomButton(
                      text: "المتسابقين الصغار",
                      backgroundColor: selectedType == "child_inscription"
                          ? AppColors.primaryColor
                          : AppColors.whiteColor,
                      minimumSize: const Size(double.infinity, 70.0),
                      textStyle: TextStyle(
                        color: selectedType == "child_inscription"
                            ? AppColors.whiteColor
                            : AppColors.blackColor,
                      ),
                      borderSide: BorderSide(
                        color: selectedType == "child_inscription"
                            ? AppColors.primaryColor
                            : AppColors.blackColor.withOpacity(.1),
                        width: 1,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedType = "child_inscription";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<List<Inscription>>(
                stream: InscriptionService.streamContestants(
                    competitionProvider!.competition!.competitionVirsion
                        .toString(),
                    selectedType.toString(),),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                        "حدث خطأ أثناء جلب البيانات: ${snapshot.error}");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                  return SizedBox(
                    // height: MediaQuery.of(context).size.height,
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 15.0,
                      ),
                      itemCount: inscriptions.length,
                      itemBuilder: (context, index) {
                        Inscription inscription = inscriptions[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailContestantScreen(
                                  inscription: inscription,
                                  competitionType: selectedType.toString(),
                                  competitionVersion: competitionProvider!
                                      .competition!.competitionVirsion
                                      .toString(),
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                padding: const EdgeInsets.all(8.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        "المتسابق رقم : ${inscription.idInscription}"),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Divider(
                                      color:
                                          AppColors.blackColor.withOpacity(.2),
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
                                                Text(inscription.noteTajwid![
                                                            authProvider
                                                                .currentUser!
                                                                .fullName] !=
                                                        null
                                                    ? inscription.noteTajwid![
                                                            authProvider
                                                                .currentUser!
                                                                .fullName]
                                                        .toString()
                                                    : "0"),
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
                                                Text(inscription.noteHousnSawtt![
                                                            authProvider
                                                                .currentUser!
                                                                .fullName] !=
                                                        null
                                                    ? inscription
                                                        .noteHousnSawtt![
                                                            authProvider
                                                                .currentUser!
                                                                .fullName]
                                                        .toString()
                                                    : "0"),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: selectedType ==
                                              "adult_inscription",
                                          child: Expanded(
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                      "الإلتزام بالرواية"),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  inscription.noteIltizamRiwaya !=
                                                          null
                                                      ? Text(inscription
                                                                      .noteIltizamRiwaya![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName] !=
                                                              null
                                                          ? inscription
                                                              .noteIltizamRiwaya![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName]
                                                              .toString()
                                                          : "0")
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: selectedType ==
                                              "child_inscription",
                                          child: Expanded(
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Text("عذوبة الصوت"),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  inscription.noteOu4oubetSawtt !=
                                                          null
                                                      ? Text(inscription
                                                                      .noteOu4oubetSawtt![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName] !=
                                                              null
                                                          ? inscription
                                                              .noteOu4oubetSawtt![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName]
                                                              .toString()
                                                          : "0")
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Visibility(
                                          visible: selectedType ==
                                              "child_inscription",
                                          child: Expanded(
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  const Text("الوقف والإبتداء"),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  inscription.noteWaqfAndIbtidaa !=
                                                          null
                                                      ? Text(inscription
                                                                      .noteWaqfAndIbtidaa![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName] !=
                                                              null
                                                          ? inscription
                                                              .noteWaqfAndIbtidaa![
                                                                  authProvider
                                                                      .currentUser!
                                                                      .fullName]
                                                              .toString()
                                                          : "0")
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: inscription.result![
                                        authProvider.currentUser!.fullName] !=
                                    null,
                                child: const Positioned(
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
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
            Map result = await AuthService.checkAllNotes(
                competitionProvider!.competition!.competitionVirsion.toString(),
                selectedType.toString(),
                authProvider.currentUser!.fullName);
            bool isCheked = result["result"];
            List<Map<String, dynamic>> dataList = result["dataList"];
            if (isCheked && dataList.isNotEmpty) {
              // Send notes to the admin
              InscriptionService.exportDataAsXlsx(
                  dataList,
                  authProvider.currentUser!.fullName,
                  competitionProvider!.competition!.competitionVirsion
                      .toString(),
                  selectedType.toString(),
                  context);
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
/*
showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => AlertDialog(
                              title: const Text("تنبيه"),
                              content: const Text("اختر مستوى المسابقة "),
                              actions: [
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButton<String>(
                                          hint: const Text("اختر مستوى"),
                                          isExpanded: true,
                                          items: ["2023-2024", "2024-2025"]
                                              .map((value) =>
                                                  DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: const TextStyle(
                                                          color: AppColors
                                                              .blackColor),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedType = value;
                                            });
                                          },
                                          value: selectedType,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  minimumSize: const Size(
                                                      double.infinity, 40.0),
                                                ),
                                                onPressed: () {
                                                  if (selectedType != null) {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListOfContestants(
                                                          competitionVersion:
                                                              selectedType!,
                                                          competitionType:
                                                              "adult_inscription",
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Snackbar for exception
                                                    final errorSnackBar =
                                                        SnackBar(
                                                      content: const Text(
                                                          "اختر مستوى المسابقة"),
                                                      action: SnackBarAction(
                                                        label: 'تراجع',
                                                        onPressed: () {},
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    );

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            errorSnackBar);
                                                  }
                                                },
                                                child: const Text(
                                                  "الكبار",
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.whiteColor),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  minimumSize: const Size(
                                                      double.infinity, 40.0),
                                                ),
                                                onPressed: () {
                                                  if (selectedType != null) {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListOfContestants(
                                                          competitionVersion:
                                                              selectedType!,
                                                          competitionType:
                                                              "child_inscription",
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    // Snackbar for exception
                                                    final errorSnackBar =
                                                        SnackBar(
                                                      content: const Text(
                                                          "اختر مستوى المسابقة"),
                                                      action: SnackBarAction(
                                                        label: 'تراجع',
                                                        onPressed: () {},
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    );

                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                            errorSnackBar);
                                                  }
                                                },
                                                child: const Text(
                                                  "الصغار",
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.whiteColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        
*/