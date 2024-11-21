import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/screens/client/home_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/inscription_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final Jury? jury;
  final Admin? admin;
  final Inscription? inscription;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.jury,
    this.inscription,
    this.admin,
  });

  @override
  OtpVerificationScreenState createState() => OtpVerificationScreenState();
}

class OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _verificationId;
  Timer? _timer;
  int _timeRemaining = 120; // 2 minutes
  bool _isOtpExpired = false;

  @override
  void initState() {
    super.initState();
    sendOtp();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void sendOtp() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      timeout: const Duration(seconds: 120),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // يقوم Firebase بالتحقق تلقائيًا من OTP
        await _auth.signInWithCredential(credential);
        navigateAfterVerification();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحقق: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _isOtpExpired = true;
        });
      },
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        setState(() {
          _isOtpExpired = true;
        });
        _timer?.cancel();
      }
    });
  }

  Future<void> onVerify() async {
    final enteredOtp = _otpController.text.trim();
    if (_verificationId != null) {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: enteredOtp,
        );

        await _auth.signInWithCredential(credential);
        navigateAfterVerification();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رمز التحقق غير صحيح')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل التحقق. حاول مرة أخرى.')),
      );
    }
  }

  void navigateAfterVerification() async {
    if (widget.jury != null) {
      // تسجيل الحساب في Firestore
      await AuthService.registerUser(jury: widget.jury, context: context);
    } else if (widget.admin != null) {
      await AuthService.registerUser(admin: widget.admin, context: context);
    } else if (widget.inscription != null) {
      await InscriptionService.sendToFirebase(
        widget.inscription!,
        context,
        Provider.of<CompetitionProvider>(context, listen: false).competition!,
      );
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('التحقق من رمز التحقق'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _isOtpExpired
                  ? 'انتهت صلاحية الرمز. أعد إرسال الرمز.'
                  : 'تبقى $_timeRemaining ثانية لإدخال الرمز.',
              style:
                  TextStyle(color: _isOtpExpired ? Colors.red : Colors.green),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رمز التحقق',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isOtpExpired ? null : onVerify,
              child: const Text('تحقق'),
            ),
            if (_isOtpExpired)
              TextButton(
                onPressed: () {
                  setState(() {
                    _timeRemaining = 120;
                    _isOtpExpired = false;
                  });
                  sendOtp();
                  startTimer();
                },
                child: const Text('إعادة إرسال الرمز'),
              ),
          ],
        ),
      ),
    );
  }
}
