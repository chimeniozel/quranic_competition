import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/quranic_benefit.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class AddQuranicBenefitScreen extends StatefulWidget {
  const AddQuranicBenefitScreen({super.key});

  @override
  State<AddQuranicBenefitScreen> createState() =>
      _AddQuranicBenefitScreenState();
}

class _AddQuranicBenefitScreenState extends State<AddQuranicBenefitScreen> {
  final TextEditingController controller = TextEditingController();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة فائدة قرآنية'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة فائدة قرآنية',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20.0,
            ),
            InputWidget(
              label: "فائدة قرآنية",
              controller: controller,
              hint: "فائدة قرآنية",
              maxLines: 5,
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                minimumSize: const Size(
                  double.infinity,
                  45.0,
                ),
              ),
              onPressed: () {
                setState(() {
                  isloading = true;
                });
                if (controller.text.isNotEmpty) {
                  // Save the benefit to the database
                  QuranicBenefit quranicBenefit = QuranicBenefit(
                    description: controller.text,
                    addByName:
                        Provider.of<AuthProviders>(context, listen: false)
                            .currentAdmin!
                            .fullName,
                  );
                  QuranicBenefit.addQuranicBenefit(quranicBenefit, context);
                  controller.clear();
                } else {
                  final failureSnackBar = SnackBar(
                    content: const Text("لا يمكن أن يكون الحقل فارغا !"),
                    action: SnackBarAction(
                      label: 'تراجع',
                      onPressed: () {},
                    ),
                    backgroundColor: AppColors.yellowColor,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
                }

                setState(() {
                  isloading = false;
                });
              },
              child: isloading
                  ? const CircularProgressIndicator(
                      color: AppColors.whiteColor,
                    )
                  : const Text(
                      'حفظ',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
