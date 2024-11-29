import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final String level;
  const QuizScreen({super.key, required this.level});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool showAnswers = false;
  List<QuizModel> quizData = [];

  Future<List<QuizModel>> fetchQuizData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('level', isEqualTo: widget.level)
          .get();
      setState(() {
        quizData = snapshot.docs
            .map((doc) => QuizModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
      return quizData;
    } catch (e) {
      debugPrint("Error fetching quiz data: $e");
      return [];
    }
  }

  @override
  void initState() {
    fetchQuizData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // List<QuizModel> quizData = snapshot.data!;
    String? correctAnswer;
    List<String>? options;
    String? questionText;
    if (quizData.isNotEmpty) {
      QuizModel currentQuestion = quizData[currentQuestionIndex];
       questionText = currentQuestion.question;
       options = List<String>.from(currentQuestion.options);
       correctAnswer = currentQuestion.correctAnswer;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('اختبر نفسك'),
      ),
      body: quizData.isEmpty
          ? const Center(
              child: Text('لا توجد أسئلة متاحة في هذا المستوى'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السؤال ${currentQuestionIndex + 1}: $questionText',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...options!.map((option) {
                    Color? answerColor;
                    if (showAnswers) {
                      if (option == correctAnswer) {
                        answerColor = Colors.green; // الإجابة الصحيحة
                      } else if (option == selectedAnswer) {
                        answerColor = Colors.red; // الإجابة الخاطئة
                      }
                    }
                    return ListTile(
                      title: Text(option),
                      tileColor: answerColor,
                      leading: Radio<String>(
                        value: option,
                        groupValue: selectedAnswer,
                        onChanged: showAnswers
                            ? null
                            : (value) {
                                setState(() {
                                  selectedAnswer = value;
                                  if (value == correctAnswer) {
                                    score++;
                                  }
                                  showAnswers = true;
                                });
                              },
                      ),
                    );
                  }),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        onPressed: () {
                          if (showAnswers) {
                            if (currentQuestionIndex < quizData.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                                selectedAnswer = null;
                                showAnswers = false;
                              });
                            } else {
                              _showScoreDialog(quizData.length);
                            }
                          }
                        },
                        child: Text(
                          currentQuestionIndex < quizData.length - 1
                              ? 'التالي'
                              : 'إنهاء',
                          style: const TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                      Text("${quizData.length} / ${currentQuestionIndex + 1}"),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _showScoreDialog(int totalQuestions) {
    bool passed = score >= totalQuestions / 2; // تحديد المعدل المطلوب للنجاح
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('نتيجتك'),
          content: Text(
            'حصلت على $score من $totalQuestions',
            style: TextStyle(color: passed ? Colors.green : Colors.red),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentQuestionIndex = 0;
                  score = 0;
                  selectedAnswer = null;
                  showAnswers = false;
                });
              },
              child: const Text('إعادة'),
            ),
          ],
        );
      },
    );
  }
}
