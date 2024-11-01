import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class CompetitionResults extends StatefulWidget {
  final Competition competition;
  const CompetitionResults({super.key, required this.competition});

  @override
  CompetitionResultsState createState() => CompetitionResultsState();
}

class CompetitionResultsState extends State<CompetitionResults> {
  bool isLoadingFirst = false;
  bool isLoadingLast = false;
  final List<String> competitionPhases = [
    "التصفيات الأولى",
    "التصفيات النهائية"
  ];

  final List<String> competitionTypes = [
    "المتسابقين الكبار",
    "المتسابقين الصغار"
  ];
  String? selectedType;
  String? selectedText;
  String? selectedRound = "التصفيات الأولى";
  bool isPassedFirstRound = false;
  String query = "";

  @override
  Widget build(BuildContext context) {
    Competition competition = widget.competition;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60.0,
        title: Text(
          "نتائج ${widget.competition.competitionVirsion.toString()}",
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await CompetitionService.publishResults(
                  competition: competition,
                  competitionRound: "التصفيات الأولى",
                  context: context);
            },
            child: const Column(
              children: [
                Icon(Iconsax.share5),
                Text(
                  "نشر النتائج 1",
                  style: TextStyle(fontSize: 9.0),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await CompetitionService.publishResults(
                  competition: competition,
                  competitionRound: "التصفيات النهائية",
                  context: context);
            },
            child: const Column(
              children: [
                Icon(Iconsax.share5),
                Text(
                  "نشر النتائج 2",
                  style: TextStyle(fontSize: 9.0),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Provider.of<CompetitionProvider>(context, listen: false)
                      .competition !=
                  null)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            // minimumSize: const Size(double.infinity, 45.0),
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            padding: const EdgeInsets.all(5.0)),
                        onPressed: () async {
                          setState(() {
                            isLoadingFirst = true;
                          });
                          bool isCorrected =
                              await CompetitionService.calculeResults(
                                  competition.competitionVirsion!,
                                  "التصفيات الأولى");
                          if (isCorrected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم حساب المعدلات الأولية بنجاح.',
                                ),
                                backgroundColor: AppColors.greenColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'لم تنتهي لجنة التحكيم من التصحيح',
                                ),
                                backgroundColor: AppColors.yellowColor,
                              ),
                            );
                          }
                          setState(() {
                            isLoadingFirst = false;
                          });
                        },
                        child: isLoadingFirst
                            ? const CircularProgressIndicator(
                                color: AppColors.whiteColor,
                              )
                            : const Text(
                                'حساب النتائج الأولية',
                                style: TextStyle(
                                  color: AppColors.whiteColor,
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
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          // minimumSize: const Size(double.infinity, 45.0),
                          padding: const EdgeInsets.all(5.0),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLoadingLast = true;
                          });
                          bool isCorrected =
                              await CompetitionService.calculeResults(
                                  competition.competitionVirsion!,
                                  "التصفيات النهائية");
                          if (isCorrected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم حساب المعدلات الأولية بنجاح.',
                                ),
                                backgroundColor: AppColors.greenColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'لم تنتهي لجنة التحكيم من التصحيح',
                                ),
                                backgroundColor: AppColors.yellowColor,
                              ),
                            );
                          }
                          setState(() {
                            isLoadingLast = false;
                          });
                        },
                        child: isLoadingLast
                            ? const CircularProgressIndicator(
                                color: AppColors.whiteColor,
                              )
                            : const Text(
                                'حساب النتائج النهائية',
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                ),
                              ),
                      ),
                    )
                  ],
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
                  // hint: const Text("اختر مرحلة"),
                  isExpanded: true,
                  underline: Container(),
                  value: selectedRound,
                  items: competitionPhases
                      .map(
                        (String phase) => DropdownMenuItem(
                          value: phase,
                          child: Text(phase),
                        ),
                      )
                      .toList(),
                  onChanged: (String? phase) {
                    setState(() {
                      selectedRound = phase;
                      if (phase == "التصفيات الأولى") {
                        isPassedFirstRound = false;
                      } else {
                        isPassedFirstRound = true;
                      }
                    });
                  },
                ),
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
                  hint: const Text("اختر فئة"),
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
                height: 15.0,
              ),
              if (selectedType != null)
                Column(
                  children: [
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
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
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
                      height: 5.0,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: FutureBuilder<List<Inscription>>(
                        future: CompetitionService.getResults(
                          isAdmin: true,
                          competition: competition,
                          competitionType: selectedType!,
                          competitionRound: selectedRound!,
                          isPassedFirstRound: isPassedFirstRound,
                          query: query,
                        ),
                        builder: (context, snapshotInscription) {
                          if (snapshotInscription.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshotInscription.hasData &&
                              snapshotInscription.data!.isNotEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: snapshotInscription.data!.length,
                                    itemBuilder: (context, index) {
                                      Inscription inscription =
                                          snapshotInscription.data![index];
                                      return Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.only(
                                                bottom: 5.0),
                                            decoration: const BoxDecoration(
                                              color: AppColors.whiteColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              boxShadow: [
                                                BoxShadow(
                                                  offset: Offset(0.0, 2.0),
                                                  blurRadius: 10.0,
                                                  color: Colors.black12,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        "رقم التسجيل",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
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
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "${inscription.fullName}"),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      const Text(
                                                        "المعدل العام",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        inscription
                                                            .resultFirstRound!
                                                            .toStringAsFixed(2),
                                                        style: TextStyle(
                                                          color: inscription
                                                                      .resultFirstRound! >=
                                                                  14
                                                              ? AppColors
                                                                  .greenColor
                                                              : AppColors
                                                                  .pinkColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                if (selectedRound != null &&
                                    selectedType != null)
                                  Flexible(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          minimumSize: const Size(
                                              double.infinity, 45.0)),
                                      onPressed: () async {
                                        InscriptionService
                                            .exportFinalResultAsXlsx(
                                                snapshotInscription.data!,
                                                competition,
                                                selectedType!,
                                                context,
                                                selectedRound!);
                                      },
                                      child: const Text(
                                        "تنزيل النتائج",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          } else {
                            return const Center(child: Text("لا توجد نتائج"));
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
