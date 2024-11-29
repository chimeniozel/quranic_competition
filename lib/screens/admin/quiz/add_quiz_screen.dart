import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/quiz_model.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class AddQuizScreen extends StatefulWidget {
  final QuizModel? quizModel;
  const AddQuizScreen({super.key, this.quizModel});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionControllers = List.generate(4, (_) => TextEditingController());
  final _correctAnswerController = TextEditingController();
  String _selectedLevel = "المستوى الأول";

  final List<String> levels = [
    'المستوى الأول',
    'المستوى الثاني',
    'المستوى الثالث'
  ];

  Future<void> _addQuiz() async {
    if (_formKey.currentState!.validate()) {
      QuizModel quizModel = QuizModel(
        question: _questionController.text,
        options:
            _optionControllers.map((controller) => controller.text).toList(),
        correctAnswer: _correctAnswerController.text,
        level: _selectedLevel,
      );

      await FirebaseFirestore.instance
          .collection('quizzes')
          .add(quizModel.toMap())
          .then(
        (DocumentReference docRef) {
          FirebaseFirestore.instance
              .collection('quizzes')
              .doc(docRef.id)
              .update({
            "id": docRef.id,
          });
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.greenColor,
          content: Text('تمت إضافة الاختبار بنجاح!'),
        ),
      );

      // Clear form
      _formKey.currentState!.reset();
      _questionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      _correctAnswerController.clear();
      // setState(() => _selectedLevel = null);
    }
  }

  Future<void> _updateQuiz() async {
    if (_formKey.currentState!.validate()) {
      QuizModel quizModel = QuizModel(
        id: widget.quizModel?.id,
        question: _questionController.text,
        options:
            _optionControllers.map((controller) => controller.text).toList(),
        correctAnswer: _correctAnswerController.text,
        level: _selectedLevel,
      );

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(quizModel.id)
          .update(quizModel.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.greenColor,
          content: Text('تم تعديل الاختبار بنجاح!'),
        ),
      );
      // Navigate back
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    if (widget.quizModel != null) {
      _questionController.text = widget.quizModel!.question;
      _correctAnswerController.text = widget.quizModel!.correctAnswer;
      _selectedLevel = widget.quizModel!.level;
      for (var i = 0; i < widget.quizModel!.options.length; i++) {
        _optionControllers[i].text = widget.quizModel!.options[i];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: Text(
              widget.quizModel != null ? 'تعديل الاختبار' : 'إضافة اختبار')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                InputWidget(
                  controller: _questionController,
                  label: "سؤال",
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال سؤال' : null,
                  hint: 'سؤال',
                ),
                const SizedBox(height: 10),
                ..._optionControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Column(
                    children: [
                      InputWidget(
                        controller: controller,
                        label: 'خيار ${index + 1}',
                        hint: 'خيار ${index + 1}',
                        validator: (value) => value!.isEmpty
                            ? 'الرجاء إدخال خيار ${index + 1}'
                            : null,
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }),
                InputWidget(
                  controller: _correctAnswerController,
                  label: "الإجابة الصحيحة",
                  hint: "الإجابة الصحيحة",
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الإجابة الصحيحة' : null,
                ),
                const SizedBox(height: 10),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    value: _selectedLevel,
                    items: levels
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLevel = value!),
                    validator: (value) =>
                        value == null ? 'الرجاء تحديد المستوى' : null,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: widget.quizModel != null ? _updateQuiz : _addQuiz,
                  child: Text(
                    widget.quizModel != null
                        ? 'تعديل الاختبار'
                        : 'إضافة اختبار',
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
