import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/admin/about_us/about_us_screen.dart';
import 'package:quranic_competition/screens/admin/benefits/quranic_benefit_screen.dart';
import 'package:quranic_competition/screens/admin/quiz/levels_screen.dart';
import 'package:quranic_competition/screens/client/competition_results_client.dart';
import 'package:quranic_competition/screens/client/competitions_screen.dart';
import 'package:quranic_competition/screens/client/inscription_screen.dart';
import 'package:quranic_competition/screens/admin/quiz/quiz_screen.dart';
import 'package:quranic_competition/screens/client/tajweed/tajweed_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'مسابقة أهل القرآن الواتسابية',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Navigate to the competitions screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text(
              "تسجيل الدخول",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Consumer<CompetitionProvider>(builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Padding(
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
                        imageAsset: "assets/images/inscription.png",
                        onTap: () {
                          if (provider.competition != null) {
                            if ((provider.competition!.adultNumber !=
                                        provider.competition!.adultNumberMax ||
                                    provider.competition!.childNumber !=
                                        provider.competition!.childNumberMax) &&
                                !provider.competition!.firstRoundIsPublished! &&
                                provider.competition!.isInscriptionOpen!) {
                              // Navigate to the inscription screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const InscriptionScreen(),
                                ),
                              );
                            } else if (provider
                                    .competition!.firstRoundIsPublished! ||
                                !provider.competition!.isInscriptionOpen!) {
                              final failureSnackBar = SnackBar(
                                content: const Text(
                                    "تم قفل باب التسجيل في المسابقة"),
                                action: SnackBarAction(
                                  label: 'تراجع',
                                  onPressed: () {},
                                ),
                                backgroundColor: AppColors.yellowColor,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(failureSnackBar);
                            } else {
                              final failureSnackBar = SnackBar(
                                content: const Text(
                                    "لا يمكن التسجيل في المسابقة , فقد وصلت إلى الحد الأقصي للمتسابقين"),
                                action: SnackBarAction(
                                  label: 'تراجع',
                                  onPressed: () {},
                                ),
                                backgroundColor: AppColors.yellowColor,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(failureSnackBar);
                            }
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
                        text: "أرشيف المسابقة",
                        imageAsset: "assets/images/archive.png",
                        onTap: () {
                          // Navigate to the inscription screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArchiveScreen(),
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
                          if (provider.competition != null) {
                            if ((provider.competition!.firstRoundIsPublished! ||
                                provider.competition!.lastRoundIsPublished!)) {
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
                                content: const Text("لم يتم نشر النتائج !"),
                                action: SnackBarAction(
                                  label: 'تراجع',
                                  onPressed: () {},
                                ),
                                backgroundColor: AppColors.yellowColor,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(failureSnackBar);
                            }
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TajweedScreen(),
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
                        text: "فوائد قرآنية",
                        imageAsset: "assets/images/فوائد قرآنية.png",
                        onTap: () {
                          // Navigate to the benefits screen
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LevelsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
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
