import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/admin/competition_management/about_us/about_us_screen.dart';
import 'package:quranic_competition/screens/admin/competition_management/quranic_benefit_screen.dart';
import 'package:quranic_competition/screens/competition_results_client.dart';
import 'package:quranic_competition/screens/competitions_screen.dart';
import 'package:quranic_competition/screens/inscription_screen.dart';
import 'package:quranic_competition/widgets/custtom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    CompetitionProvider competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'مسابقة أهل القرآن الواتسابية',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/images/logos/logo.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomCard(
                        text: "التسجيل في المسابقة",
                        imageAsset: "assets/images/inscription.jpeg",
                        onTap: () {
                          if (competitionProvider.competition != null &&
                              DateTime.now().isBefore(
                                  competitionProvider.competition!.endDate!)) {
                            // Navigate to the inscription screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InscriptionScreen(),
                              ),
                            );
                          } else {
                            final failureSnackBar = SnackBar(
                              content:
                                  const Text("لا توجد مسابقة نشطة حاليا !"),
                              action: SnackBarAction(
                                label: 'تراجع',
                                onPressed: () {},
                              ),
                              backgroundColor: AppColors.yellowColor,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(failureSnackBar);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: CusttomCard(
                        text: "أرشيف المسابقات",
                        imageAsset: "assets/images/archive.jpeg",
                        onTap: () {
                          // Navigate to the inscription screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompetitionsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomCard(
                        text: "نتائج المسابقة",
                        imageAsset: "assets/images/results.jpeg",
                        onTap: () {
                          if (competitionProvider.competition != null) {
                            // Navigate to the inscription screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CompetitionResultsClient(),
                              ),
                            );
                          } else {
                            final failureSnackBar = SnackBar(
                              content:
                                  const Text("لا توجد مسابقة نشطة حاليا !"),
                              action: SnackBarAction(
                                label: 'تراجع',
                                onPressed: () {},
                              ),
                              backgroundColor: AppColors.yellowColor,
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(failureSnackBar);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: CusttomCard(
                        text: "أحكام التجويد",
                        imageAsset: "assets/images/tejweed.png",
                        onTap: () {
                          // Navigate to the inscription screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const InscriptionScreen(),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomCard(
                        text: "فوائد قرآنية",
                        imageAsset: "assets/images/فوائد قرآنية.jpeg",
                        onTap: () {
                          // Navigate to the inscription screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const QuranicBenefitScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: CusttomCard(
                        text: "أسئلة وأجوبة في القرآن",
                        imageAsset:
                            "assets/images/أسئلة_وأجوبة_عن_القرآن_الكريم.jpeg",
                        onTap: () {
                          // Navigate to the inscription screen
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const InscriptionScreen(),
                          //   ),
                          // );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50.0,
        // width: 45.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            // maximumSize: const Size(50, 45.0)
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.info_circle,
                color: AppColors.whiteColor,
              ),
              Text(
                "من نحن",
                style: TextStyle(
                  color: AppColors.whiteColor,
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AboutUsScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
