import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class JuryResults extends StatefulWidget {
  final Competition competition;
  const JuryResults({super.key, required this.competition});

  @override
  State<JuryResults> createState() => _JuryResultsState();
}

class _JuryResultsState extends State<JuryResults> {
  List<Users> juryUsers = [];
  Users? selectedUsers;
  String? selectedType;
  String? selectedText;

  @override
  void initState() {
    getJuryUsers();
    super.initState();
  }

  Future<void> getJuryUsers() async {
    List<Users> jury = await CompetitionService.getJuryUsers();
    setState(() {
      juryUsers = jury;
    });
  }

  @override
  Widget build(BuildContext context) {
    Competition competition = widget.competition;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تصحيح لجنة التحكيم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
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
                    child: DropdownButton<String>(
                      hint: const Text("اختر فئة"),
                      underline: Container(),
                      isExpanded: true,
                      value: selectedText,
                      items: ["فئة الكبار", "فئة الصغار"]
                          .map(
                            (String type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(
                                type,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == "فئة الكبار") {
                          setState(() {
                            selectedText = value;
                            selectedType = "adult_inscription";
                          });
                        } else {
                          setState(() {
                            selectedText = value;
                            selectedType = "child_inscription";
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                Expanded(
                  child: Container(
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
                    child: DropdownButton<Users>(
                      hint: const Text("اختر شيخا"),
                      underline: Container(),
                      isExpanded: true,
                      value: selectedUsers,
                      items: juryUsers
                          .map(
                            (Users user) => DropdownMenuItem<Users>(
                              value: user,
                              child: Text(
                                user.fullName,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (selectedType != null) {
                          setState(() {
                            selectedUsers = value;
                          });
                        } else {
                          // Snackbar for failure
                          final successSnackBar = SnackBar(
                            content: const Text('اختر فئة ثم اختر الشيخ'),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            selectedUsers != null
                ? Flexible(
                    child: FutureBuilder<List<Inscription>>(
                      future: InscriptionService.fetchContestantsByJury(
                          competition, selectedType!, selectedUsers!.fullName, "التصفيات الأولى"),
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
                                            "رقم المتسابق",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                            "المجموع",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(inscription
                                              .result![selectedUsers!.fullName]
                                              .toString()),
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
                            child: Text("لم ينتهي هذا الشيخ من التصحيح"),
                          );
                        }
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
