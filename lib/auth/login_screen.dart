import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/auth/register_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/competition_management/competition_management.dart';
import 'package:quranic_competition/screens/home_screen.dart';
import 'package:quranic_competition/screens/jury/jury_home_screen.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePass = true;
  bool loading = false;

  @override
  void initState() {
    phoneNumberController.text = "46669696";
    passwordController.text = "12345678";
    super.initState();
  }

  getStoragePermissions() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("تسجيل الدخول"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/logos/logo.png",
                height: 300,
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
                  setState(() {
                    loading = true;
                  });
                  Users user = Users(
                    fullName: "fullName",
                    phoneNumber: phoneNumberController.text,
                    password: passwordController.text,
                  );
                  Map data = await authProvider.loginUser(user, context);
                  bool loggedIn = data["loggedIn"];
                  Users? currentUser = data["currentUser"];
                  if (loggedIn && currentUser != null) {
                    if (currentUser.role == "عضو لجنة التحكيم") {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JuryHomeScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompetitionManagement(),
                        ),
                        (route) => false,
                      );
                    }
                  } else {
                    setState(() {
                      loading = false;
                    });
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        title: const Text("خطأ"),
                        content: const Text(
                          "رقم الهاتف أو كلمة المرور خاطئة ",
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
                              "حسنا",
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: loading
                    ? const CircularProgressIndicator(
                        color: AppColors.whiteColor,
                      )
                    : const Text(
                        "تسجيل الدخول",
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
                  const Text("ليس لديك حساب"),
                  TextButton(
                    style: TextButton.styleFrom(
                      overlayColor: Colors.transparent,
                    ),
                    onPressed: () {
                      // Navigate to the login screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text("أنشئ حسابا"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "المتابعة كزائر",
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
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
            child: const Text(
              "تفضل بالضغط هنا",
            ),
          ),
        ],
      ),
    );
  }
}
