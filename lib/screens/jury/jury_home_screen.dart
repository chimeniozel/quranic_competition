import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/jury/list_of_contestants.dart';
import 'package:quranic_competition/widgets/row_button_widget.dart';

class JuryHomeScreen extends StatefulWidget {
  const JuryHomeScreen({super.key});

  @override
  State<JuryHomeScreen> createState() => _JuryHomeScreenState();
}

class _JuryHomeScreenState extends State<JuryHomeScreen> {
  String? selectedVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لجنة التحكيم"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/logo/logo.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomButton(
                        text: "لائحة المتسابقين",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(double.infinity, 70.0),
                        style: const TextStyle(color: AppColors.whiteColor),
                        onPressed: () {
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
                                              selectedVersion = value;
                                            });
                                          },
                                          value: selectedVersion,
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
                                                  if (selectedVersion != null) {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListOfContestants(
                                                          competitionVersion:
                                                              selectedVersion!,
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
                                                  if (selectedVersion != null) {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ListOfContestants(
                                                          competitionVersion:
                                                              selectedVersion!,
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
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
