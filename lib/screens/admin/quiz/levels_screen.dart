import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/quiz/add_quiz_screen.dart';
import 'package:quranic_competition/screens/admin/quiz/all_quiz_screen.dart';
import 'package:quranic_competition/screens/admin/quiz/quiz_screen.dart';

class LevelsScreen extends StatelessWidget {
  LevelsScreen({super.key});

  final List<String> levels = [
    'المستوى الأول',
    'المستوى الثاني',
    'المستوى الثالث'
  ];

  void _navigateToQuizzes(BuildContext context, String level) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(level: level),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthProviders providers =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('حدد مستوى'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _navigateToQuizzes(context, levels[0]),
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/level1.png"),
                      Text(
                        levels[0],
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToQuizzes(context, levels[1]),
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/level2.png"),
                      Text(
                        levels[1],
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _navigateToQuizzes(context, levels[2]),
              child: Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/level3.png"),
                      Text(
                        levels[2],
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: providers.currentAdmin != null
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: const Size(50, 50),
                    ),
                    onPressed: () {
                      // Navigate to add quiz screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddQuizScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Iconsax.add,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: const Size(50, 50),
                    ),
                    onPressed: () {
                      // Navigate to add quiz screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllQuizScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Iconsax.message_question,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class QuizzesScreen extends StatelessWidget {
  final String level;

  const QuizzesScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(backgroundColor: AppColors.primaryColor, title: Text(level)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('level', isEqualTo: level)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('لا توجد اختبارات متاحة لهذا المستوى.'));
          }
          final quizzes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(quiz['question']),
              );
            },
          );
        },
      ),
    );
  }
}
