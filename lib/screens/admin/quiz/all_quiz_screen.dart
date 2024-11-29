import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/quiz_model.dart';
import 'package:quranic_competition/screens/admin/quiz/add_quiz_screen.dart';

class AllQuizScreen extends StatefulWidget {
  const AllQuizScreen({super.key});

  @override
  State<AllQuizScreen> createState() => _AllQuizScreenState();
}

class _AllQuizScreenState extends State<AllQuizScreen> {
  String _selectedLevel = "المستوى الأول";

  final List<String> levels = [
    'المستوى الأول',
    'المستوى الثاني',
    'المستوى الثالث'
  ];

  Stream<List<QuizModel>> fetchQuizData(String level) {
    try {
      return FirebaseFirestore.instance
          .collection('quizzes')
          .where('level', isEqualTo: level)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  QuizModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList());
    } catch (e) {
      debugPrint("Error fetching quiz data: $e");
      // Return an empty stream in case of an error
      return Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('الأسئلة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
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
              child: DropdownButtonFormField<String>(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                value: _selectedLevel,
                items: levels
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
                validator: (value) =>
                    value == null ? 'الرجاء تحديد المستوى' : null,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: StreamBuilder<List<QuizModel>>(
                stream: fetchQuizData(_selectedLevel),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('حدث خطأ أثناء تحميل البيانات'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('لا توجد أسئلة متاحة في هذا المستوى'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      QuizModel quizModel = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddQuizScreen(
                                quizModel: quizModel,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 5.0),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("السؤال : ${quizModel.question}"),
                                    const SizedBox(
                                      height: 8.0,
                                    ),
                                    Text("الجواب : ${quizModel.correctAnswer}"),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("تأكيد الحذف"),
                                        content: const Text(
                                            "هل أنت متأكد أنك تريد حذف هذا السؤال؟"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: const Text("إلغاء"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              FirebaseFirestore.instance
                                                  .collection("quizzes")
                                                  .doc(quizModel.id)
                                                  .delete();
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "حذف",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  IconlyLight.delete,
                                  color: AppColors.pinkColor,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
