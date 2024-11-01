import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionResultsClient extends StatefulWidget {
  const CompetitionResultsClient({super.key});

  @override
  State<CompetitionResultsClient> createState() =>
      _CompetitionResultsClientState();
}

class _CompetitionResultsClientState extends State<CompetitionResultsClient> {
  final List<String> competitionPhases = [
    "التصفيات الأولى",
    "التصفيات النهائية"
  ];
  String selectedType = "adult_inscription";
  String? selectedRound = "التصفيات الأولى";
  bool isPassedFirstRound = false;

  String query = "";
  @override
  Widget build(BuildContext context) {
    CompetitionProvider competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج المسابقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(
              height: 15.0,
            ),
            if (selectedRound != null)
              Flexible(
                child: TextFormField(
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
              ),
            const SizedBox(
              height: 5.0,
            ),
            Expanded(
              child: FutureBuilder<List<Inscription>>(
                future: CompetitionService.getResults(
                  isAdmin: false,
                  competition: competitionProvider
                      .competition!,
                  competitionType: selectedType,
                  competitionRound: selectedRound!,
                  isPassedFirstRound: isPassedFirstRound,
                  query: query,
                ),
                builder: (context, snapshotInscription) {
                  if (snapshotInscription.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshotInscription.hasData &&
                      snapshotInscription.data!.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshotInscription.data!.length,
                      itemBuilder: (context, index) {
                        Inscription inscription =
                            snapshotInscription.data![index];
                        return Container(
                          padding: const EdgeInsets.all(8.0),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "رقم التسجيل",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("${inscription.idInscription}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "الإسم الكامل",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text("${inscription.fullName}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "المعدل العام",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      inscription.resultFirstRound!
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        color:
                                            inscription.resultFirstRound! >= 14
                                                ? AppColors.greenColor
                                                : AppColors.pinkColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("لا توجد نتائج"));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
