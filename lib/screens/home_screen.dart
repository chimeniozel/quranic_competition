import 'package:flutter/material.dart';
import 'package:quranic_competition/auth/register_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/screens/inscription_screen.dart';
import 'package:quranic_competition/widgets/row_button_widget.dart';

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
        title: const Text(
          'مسابقة أهل القرآن الواتسابية',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/logo/logo.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomButton(
                        text: "التسجيل في المسابقة",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {
                          // Navigate to the inscription screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InscriptionScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: CusttomButton(
                        text: "أرشيف المسابقة",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {
                          // Navigate to the competition schedule screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
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
                      child: CusttomButton(
                        text: "نتائج المسابقة",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: CusttomButton(
                        text: "أحكام التجويد",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CusttomButton(
                        text: "فوائد قرآنية",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: CusttomButton(
                        text: "أسئلة وأجوبة في القرآن",
                        backgroundColor: AppColors.primaryColor,
                        minimumSize: const Size(
                          double.infinity,
                          70.0,
                        ),
                        style: const TextStyle(
                          color: AppColors.whiteColor,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
