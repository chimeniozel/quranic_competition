import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/tajweed_post_model.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class AddTajweedPostScreen extends StatefulWidget {
  final TajweedPostModel? model;
  const AddTajweedPostScreen({super.key, this.model});

  @override
  State<AddTajweedPostScreen> createState() => _AddTajweedPostScreenState();
}

class _AddTajweedPostScreenState extends State<AddTajweedPostScreen> {
  TextEditingController titelController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.model != null) {
      titelController.text = widget.model!.title;
      descriptionController.text = widget.model!.content;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('إضافة منشور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              InputWidget(
                  label: "العنوان",
                  controller: titelController,
                  hint: "العنوان"),
              const SizedBox(
                height: 10.0,
              ),
              InputWidget(
                label: "المحتوى",
                controller: descriptionController,
                hint: "المحتوى",
                maxLines: 7,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: authProvider.currentAdmin != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  // Validation failed
                  return;
                }
                // Save the post to the database here
                if (widget.model == null) {
                  TajweedPostModel model = TajweedPostModel(
                    title: titelController.text,
                    content: descriptionController.text,
                    author: authProvider.currentAdmin!.fullName!,
                    createdAt: DateTime.now(),
                  );
                  // Add the post to the database
                  CompetitionService.addTajweedPost(model, context)
                      .whenComplete(() {
                    // Navigate back
                    Navigator.pop(context);
                  });
                } else {
                  widget.model!.title = titelController.text;
                  widget.model!.content = descriptionController.text;
                  // Update the post in the database
                  CompetitionService.updateTajweedPost(widget.model!, context)
                     .whenComplete(() {
                    // Navigate back
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(widget.model != null ? "تعديل" : "حفظ"),
            )
          : null,
    );
  }
}
