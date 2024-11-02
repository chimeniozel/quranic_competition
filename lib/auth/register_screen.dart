import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/verify_phone_number_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController verifyPhoneNumberController =
      TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePass = true;
  bool obscureCheck = true;

  List<String> roles = ["إداري", "عضو لجنة التحكيم"];

  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("صفحة التسجيل"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logos/logo.png",
                height: 250,
              ),
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                child: DropdownButton(
                    hint: const Text("اختر دورك"),
                    underline: Container(),
                    isExpanded: true,
                    value: selectedRole,
                    items: roles
                        .map(
                          (role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    }),
              ),
              const SizedBox(height: 10.0),
              InputWidget(
                label: "الإسم الكامل",
                controller: fullNameController,
                hint: "الإسم الكامل",
                icon: Iconsax.user,
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 10.0),
              InputWidget(
                keyboardType: TextInputType.phone,
                label: "رقم الهاتف",
                controller: phoneNumberController,
                hint: "رقم الهاتف",
                icon: Iconsax.call,
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 10.0),
              InputWidget(
                obscure: obscurePass,
                maxLines: 1,
                keyboardType: TextInputType.text,
                label: "كلمة السر",
                controller: passwordController,
                hint: "كلمة السر",
                icon: IconlyLight.password,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePass = !obscurePass;
                    });
                  },
                  icon: Icon(
                    !obscurePass ? IconlyBold.show : IconlyLight.show,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 10.0),
              InputWidget(
                obscure: obscureCheck,
                maxLines: 1,
                keyboardType: TextInputType.text,
                label: "إعادة كلمة السر",
                controller: confirmPasswordController,
                hint: "إعادة كلمة السر",
                icon: Iconsax.password_check,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureCheck = !obscureCheck;
                    });
                  },
                  icon: Icon(
                    !obscureCheck ? IconlyBold.show : IconlyLight.show,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
                onTap: () {},
                onChanged: (value) {},
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    40.0,
                  ),
                ),
                onPressed: () async {
                  if (fullNameController.text.isEmpty ||
                      phoneNumberController.text.isEmpty ||
                      passwordController.text.isEmpty ||
                      confirmPasswordController.text.isEmpty ||
                      selectedRole == null) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("خطأ"),
                        content: const Text("يرجى ملئ الحقول المطلوبة"),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                              minimumSize: const Size(
                                double.infinity,
                                40.0,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "إعادة المحاولة",
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (passwordController.text !=
                      confirmPasswordController.text) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("خطأ"),
                        content: const Text(
                          "كلمتا السر غير متطابقتين",
                        ),
                        actions: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                              ),
                              minimumSize: const Size(
                                double.infinity,
                                40.0,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "إعادة المحاولة",
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("تأكيد الرقم"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "هل هذا هو رقمك الصحيح؟",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                phoneNumberController.text,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "سوف نرسل لك رمز تأكيد إلى هذا الرقم.",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: const Text("تعديل",
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the dialog without confirming
                              },
                            ),
                            TextButton(
                              child: const Text("تأكيد",
                                  style: TextStyle(color: Colors.green)),
                              onPressed: () async {
                                // Navigator.of(context).pop(); // Close the dialog
                                Users user = Users(
                                    fullName: fullNameController.text,
                                    phoneNumber: phoneNumberController.text,
                                    password: passwordController.text,
                                    role: selectedRole!);
                                bool isSent =
                                    await AuthService.sendVerificationCode(
                                        phoneNumber: user.phoneNumber,
                                        context: context);
                                if (isSent) {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          VerifyPhoneNumberScreen(
                                        user: user,
                                        function: () {
                                          AuthService.registerUser(
                                              user, context);
                                        },
                                      ),
                                    ),
                                  );
                                }
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text(
                  "التسجيل",
                  style: TextStyle(
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "لديك حساب بالفعل",
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                    onPressed: () {
                      // Navigate to the login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "سجل الدخول",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
