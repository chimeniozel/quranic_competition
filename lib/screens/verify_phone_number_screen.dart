import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranic_competition/models/inscription.dart';

class VerifyPhoneNumberScreen extends StatefulWidget {
  final Inscription inscription;

  const VerifyPhoneNumberScreen({super.key, required this.inscription});

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  bool _isSubmitting = false;
  String? _verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _sendVerificationCode();
  }

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+222${widget.inscription.phoneNumber}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _showMessage('تم التحقق من رقم الهاتف وتسجيل الدخول تلقائيًا.');
        },
        verificationFailed: (FirebaseAuthException e) {
          _showMessage('فشل التحقق: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _showMessage('تم إرسال رمز التحقق.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _showMessage('فشل إرسال رمز التحقق: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _verifyCode() async {
    String code = _codeControllers.map((controller) => controller.text).join();
    if (code.length != 4) {
      _showMessage('يرجى إدخال الرمز الكامل.');
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await _auth.signInWithCredential(credential);
      _showMessage('تم التحقق من الرقم بنجاح!');
    } catch (e) {
      _showMessage('فشل التحقق من الرمز: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Inscription inscription = widget.inscription;

    return Scaffold(
      appBar: AppBar(
        title: Text(inscription.fullName.toString()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(inscription.fullName.toString()),
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
              onPressed: _isSubmitting ? null : _verifyCode,
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
