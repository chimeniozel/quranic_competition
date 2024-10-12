import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/result_model.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionResultsClient extends StatefulWidget {
  const CompetitionResultsClient({super.key});

  @override
  State<CompetitionResultsClient> createState() =>
      _CompetitionResultsClientState();
}

class _CompetitionResultsClientState extends State<CompetitionResultsClient> {
  final List<String> competitionPhases = ["نتائج التصفيات", "النتائج النهائية"];
  String? selectedPhase;

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
                hint: const Text("اختر مرحلة"),
                isExpanded: true,
                underline: Container(),
                value: selectedPhase,
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
                    selectedPhase = phase;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            if (selectedPhase != null)
              Flexible(
                child: TextFormField(
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
              child: FutureBuilder<List<ResultModel>>(
                future: CompetitionService.getResults(
                    selectedPhase.toString(),
                    competitionProvider.competition!.competitionVirsion
                        .toString(),
                    query),
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
                        ResultModel resultModel =
                            snapshotInscription.data![index];
                        return Container(
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
                          child: Row(
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
                                    Text("${resultModel.idUser}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "الإسم الثلاثي",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("${resultModel.fullName}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      "المعدل العام",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text("${resultModel.generalMoyenne}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text("لا توجد نتائج"),
                    );
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
