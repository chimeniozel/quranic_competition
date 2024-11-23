import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/about_us_model.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class UpdateAboutUs extends StatefulWidget {
  const UpdateAboutUs({super.key});

  @override
  State<UpdateAboutUs> createState() => _UpdateAboutUsState();
}

class _UpdateAboutUsState extends State<UpdateAboutUs> {
  TextEditingController aboutUsController = TextEditingController();
  TextEditingController facebookUrlController = TextEditingController();
  TextEditingController youtubeUrController = TextEditingController();
  TextEditingController whatsappPhoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('من نحن'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: FutureBuilder<AboutUsModel?>(
              future: CompetitionService.getAboutUs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  AboutUsModel model = snapshot.data!;
                  aboutUsController.text = model.description!;
                  facebookUrlController.text = model.facebookUrl!;
                  youtubeUrController.text = model.youtubeUrl!;
                  whatsappPhoneController.text = model.whatsappPhoneNumber!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 5.0,
                      ),
                      InputWidget(
                        label: "من نحن",
                        controller: aboutUsController,
                        hint: "من نحن",
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      InputWidget(
                        label: "رابط الفيسبوك",
                        controller: facebookUrlController,
                        hint: "رابط الفيسبوك",
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      InputWidget(
                        label: "رابط اليوتيوب",
                        controller: youtubeUrController,
                        hint: "رابط اليوتيوب",
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      InputWidget(
                        keyboardType: TextInputType.phone,
                        label: "رقم الواتساب",
                        controller: whatsappPhoneController,
                        hint: "رقم الواتساب",
                      ),
                    ],
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ : ${snapshot.error}',
                    ),
                  );
                } else {
                  return const Center(
                    child: Text(
                      'لا توجد معلومات',
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          if (!_formKey.currentState!.validate()) {
            // Validation failed
            return;
          }
          AboutUsModel model = AboutUsModel(
            description: aboutUsController.text,
            facebookUrl: facebookUrlController.text,
            youtubeUrl: youtubeUrController.text,
            whatsappPhoneNumber: whatsappPhoneController.text,
          );
          await FirebaseFirestore.instance
              .collection("about_us")
              .doc("k934z1vhO6LgWEFxex81")
              .set(model.toMap())
              .whenComplete(
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ المعلومات بنجاح'),
                  backgroundColor: AppColors.greenColor,
                ),
              );
              Navigator.pop(context);
            },
          );
        },
        child: const Text('حفظ'),
      ),
    );
  }
}
