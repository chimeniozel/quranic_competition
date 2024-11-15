import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/result_model.dart';
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
  String query = "";
  bool _isLoading = false;
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () async {
                        await CompetitionService.publishResults(
                            competition: competition,
                            competitionRound: "التصفيات الأولى",
                            context: context);
                      },
                      child: const Column(
                        children: [
                          Icon(
                            Iconsax.share5,
                            size: 30,
                          ),
                          Text(
                            "نشر النتائج الأولية",
                            style: TextStyle(fontSize: 16.0),
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
                          Icon(
                            Iconsax.share5,
                            size: 30,
                          ),
                          Text(
                            "نشر النتائج النهائية",
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
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
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: CompetitionService.getResults(
                          isAdmin: true,
                          competition: competition,
                          version: competition.competitionVirsion!,
                          competitionType: selectedType!,
                          competitionRound: selectedRound!,
                          query: query,
                        ),
                        builder: (context, snapshotInscription) {
                          if (snapshotInscription.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                                      Map<String, dynamic> map =
                                          snapshotInscription.data![index];
                                      Inscription inscription =
                                          map["inscription"];

                                      ResultModel? resultModel =
                                          map["result"] as ResultModel?;
                                      // selectedText == "المتسابقين الكبار"
                                      //     ? adultResults.add(resultModel!)
                                      //     : childResults.add(resultModel!);
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
                                                        resultModel!
                                                            .generalMoyenne!
                                                            .toStringAsFixed(2),
                                                        style: TextStyle(
                                                          color: resultModel
                                                                      .generalMoyenne! >=
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
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        List<ResultModel> resultModels = [];
                                        List<Map<String, dynamic>> map =
                                            await CompetitionService.getResults(
                                          isAdmin: true,
                                          competition: competition,
                                          version:
                                              competition.competitionVirsion!,
                                          competitionType: selectedType!,
                                          competitionRound: selectedRound!,
                                          query: query,
                                        );
                                        for (var element in map) {
                                          resultModels.add(
                                              element["result"] as ResultModel);
                                        }

                                        InscriptionService
                                                .exportFinalResultAsXlsx(
                                                    resultModels,
                                                    competition,
                                                    selectedType!,
                                                    context,
                                                    selectedRound!)
                                            .whenComplete(() {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        });
                                      },
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              strokeWidth: 5.0,
                                            )
                                          : const Text(
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
