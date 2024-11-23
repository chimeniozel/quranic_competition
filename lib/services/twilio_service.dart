import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class TwilioService {
  final String accountSid = 'AC204372ec3300cc000745dad6e23ee3c6';
  final String authToken = '043c8039958c3a50f3a7d9470dc68bfd';
  final String twilioPhoneNumber = '+18178542442';

  String generateOtp() {
    var rng = Random();
    return (rng.nextInt(9000) + 1000).toString(); // يولد رمز OTP من 6 أرقام
  }

  Future<void> sendOtp(String toPhoneNumber, String otp) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}';

    final response = await http.post(
      Uri.parse(
          'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json'),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {
        'From': twilioPhoneNumber,
        'To': toPhoneNumber,
        'Body': 'Your OTP is: $otp. It is valid for 2 minutes.'
      },
    );

    if (response.statusCode == 201) {
      print("تم إرسال رمز OTP بنجاح");
    } else {
      print("فشل في إرسال رمز OTP: ${response.body}");
    }
  }
}
