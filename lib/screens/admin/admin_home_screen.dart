import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/admin/benefits/quranic_benefit_screen.dart';
import 'package:quranic_competition/screens/admin/competition/competition_management.dart';
import 'package:quranic_competition/screens/admin/users/all_admins_screen.dart';
import 'package:quranic_competition/screens/admin/users/all_jurys_screen.dart';
import 'package:quranic_competition/screens/client/competitions_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // AuthProviders authProviders =
    //     Provider.of<AuthProviders>(context, listen: false);
    return Consumer2<CompetitionProvider, AuthProviders>(
        builder: (context, competitionProvider, authProviders, child) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 340,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(
                        40.0,
                      )),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        8.0,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.whiteColor,
                            child: Image.asset("assets/images/logos/logo.png"),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "أهلا بكم",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: AppColors.whiteColor),
                                ),
                                Text(
                                  "${authProviders.currentAdmin?.fullName}",
                                  style: const TextStyle(
                                      color: AppColors.whiteColor,
                                      fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          IconButton(
                            icon: const Icon(
                              Iconsax.logout,
                              color: AppColors.whiteColor,
                            ),
                            onPressed: () {
                              authProviders.logout(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    if (competitionProvider.competition != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.hommeAdultNumber + competitionProvider.hommeChildNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "إجمالي عدد الذكور",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.femmeAdultNumber + competitionProvider.femmeChildNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "إجمالي عدد الإناث",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.hommeAdultNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "من الكبار",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.femmeAdultNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "من الكبار",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.hommeChildNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "من الصغار",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${competitionProvider.femmeChildNumber}",
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: AppColors.whiteColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        "من الصغار",
                                        style: TextStyle(
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the competition managment
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CompetitionManagementScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/competition.png',
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'نُسح المسابقة',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the competition managment
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ArchiveScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/archive_image_video.png',
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'الأرشيف',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the competition managment
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllAdminsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/admin.png',
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'أعضاء الإدارة',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to the competition managment
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllJurysScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 150,
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/jury.png',
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  const Text(
                                    'أعضاء لجنة التحكيم',
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to the competition managment
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuranicBenefitScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        padding: const EdgeInsets.all(
                          10.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/فوائد قرآنية.png',
                              width: 70,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const Text(
                              'فوائد قرآنية',
                              style: TextStyle(fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
