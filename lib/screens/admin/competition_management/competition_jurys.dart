import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionJurys extends StatefulWidget {
  final Competition competition;
  const CompetitionJurys({super.key, required this.competition});

  @override
  State<CompetitionJurys> createState() => _CompetitionJurysState();
}

class _CompetitionJurysState extends State<CompetitionJurys> {
  Jury? selectedJury;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Competition competition = widget.competition;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          competition.competitionVirsion.toString(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (competition.isActive!)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "إضافة عضو جديد إلى هذه النسخة",
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ),
                      color: AppColors.whiteColor,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 2,
                      ),
                    ),
                    child: DropdownButton<Jury>(
                        hint: const Text("اختر شيخا"),
                        underline: Container(),
                        isExpanded: true,
                        value: selectedJury,
                        items:
                            Provider.of<AuthProviders>(context, listen: false)
                                .jurys!
                                .map(
                                  (jury) => DropdownMenuItem<Jury>(
                                    value: jury,
                                    child: Text(jury.fullName.toString()),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedJury = value;
                          });
                        }),
                  ),
                ],
              ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: FutureBuilder<List<Jury>>(
                future: CompetitionService.getCompetitionJurys(
                    competition.competitionVirsion.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Jury jury = snapshot.data![index];
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 3.0),
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
                              const CircleAvatar(),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jury.fullName.toString(),
                                    style: const TextStyle(fontSize: 16.0),
                                  ),
                                  Text(jury.phoneNumber),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'حدث خطأ : ${snapshot.error}',
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (selectedJury != null)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 45.0),
                  ),
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                    });
                    CompetitionService.addJuryToCompetition(
                      context: context,
                      comptetitionVersion:
                          competition.competitionVirsion.toString(),
                      jury: selectedJury!,
                    );
                    setState(() {
                      isLoading = false;
                      selectedJury = null;
                    });
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 5,
                        )
                      : const Text(
                          'إضافة',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.whiteColor,
                          ),
                        ),
                ),
              ),
            const SizedBox(
              width: 5.0,
            ),
            if (selectedJury != null)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pinkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 45.0),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedJury = null;
                    });
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
