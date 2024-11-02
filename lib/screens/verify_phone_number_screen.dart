import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  final Inscription? inscription;
  final String? competitionVirsion;
  final Users? user;
  final void Function() function;

  const VerifyPhoneNumberScreen(
      {super.key, this.inscription, this.user, this.competitionVirsion , required this.function});

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  bool _isSubmitting = false;
  // String? _verificationId;
  bool isSent = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // _sendVerificationCode();
  }

  @override
  Widget build(BuildContext context) {
    Inscription? inscription = widget.inscription;
    Users? user = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(inscription != null
            ? inscription.fullName.toString()
            : user!.fullName.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(inscription != null
                ? inscription.fullName.toString()
                : user!.fullName.toString()),
            const SizedBox(height: 10),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  4,
                  (index) => SizedBox(
                    height: 58,
                    width: 54,
                    child: TextFormField(
                      controller: _codeControllers[index],
                      onChanged: (value) {
                        if (value.length == 1) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: Theme.of(context).textTheme.headlineMedium,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!_isSubmitting) {
                } else {
                  AuthService.verifyCode(
                    function: widget.function,
                      codeControllers: _codeControllers, context: context);
                }
              },
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تحقق من الرمز'),
            ),
          ],
        ),
      ),
    );
  }
}
