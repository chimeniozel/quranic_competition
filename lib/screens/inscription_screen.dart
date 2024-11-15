import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/inscription_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String phoneNumberController = "";
  String selectedResudence = "داخل موريتانيا";
  String howMuchYouMemorize = "القرآن كاملا";
  String haveYouIhaza = "نعم";
  String howMuchRiwayaYouHave = "رواية واحدة";
  String haveYouParticipatedInACompetition = "نعم";
  String haveYouEverWon1stTo2ndPlace = "نعم";
  bool obscure = true;
  DateTime _selectedDate = DateTime(DateTime.now().year - 6);
  DateTime initialDate = DateTime(1970); // قيمة افتراضية كحد أدنى
  DateTime lastDate = DateTime(DateTime.now().year - 6);
  DateTime firstDate = DateTime(1970);

  List<String> howMuchYouMemorizes = ["القرآن كاملا", "نصف", "أقل من نصف"];

  // bool isLoading = false;

  String typecomp = "";

  void handleSelectedResudence(String? value) {
    setState(() {
      selectedResudence = value!;
    });
  }

  void handleHowMuchYouMemorize(String? value) {
    setState(() {
      howMuchYouMemorize = value!;
    });
  }

  void handleHaveYouIhaza(String? value) {
    setState(() {
      haveYouIhaza = value!;
    });
  }

  void handleHowMuchRiwayaYouHave(String? value) {
    setState(() {
      howMuchRiwayaYouHave = value!;
    });
  }

  void handleHaveYouParticipatedInACompetition(String? value) {
    setState(() {
      haveYouParticipatedInACompetition = value!;
    });
  }

  void handleHaveYouEverWon1stTo2ndPlace(String? value) {
    setState(() {
      haveYouEverWon1stTo2ndPlace = value!;
    });
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? pickedDate = await showDatePicker(
  //     initialEntryMode: DatePickerEntryMode.calendar,
  //     context: context,
  //     builder: (context, child) {
  //       return Theme(
  //         data: Theme.of(context).copyWith(canvasColor: Colors.white),
  //         child: child!,
  //       );
  //     },
  //     initialDate: DateTime(DateTime.now().year - 6),
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime(DateTime.now().year - 6),
  //   );

  //   if (pickedDate != null) {
  //     setState(() {
  //       _selectedDate = pickedDate;
  //       if (DateTime.now().year - _selectedDate.year >= 6 &&
  //           DateTime.now().year - _selectedDate.year < 13) {
  //         typecomp = "فئة الصغار";
  //       }
  //       if (DateTime.now().year - _selectedDate.year >= 13) {
  //         typecomp = "فئة الكبار";
  //       }
  //     });
  //   }
  // }

  final _fromKey = GlobalKey<FormState>();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Text(
          "قم بالتسجيل للبدء",
          // textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 32,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<CompetitionProvider>(builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _fromKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Name of user
                  InputWidget(
                    label: "الاسم الثلاثي",
                    controller: fullNameController,
                    hint: "الاسم الثلاثي",
                    icon: Iconsax.user,
                  ),
                  const SizedBox(height: 10.0),

                  // Phone number
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 55,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                offset: Offset(0.0, 2.0),
                                blurRadius: 10.0,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: IntlPhoneField(
                            initialCountryCode: "MR",
                            // controller: phoneNumberController,
                            dropdownIconPosition: IconPosition.trailing,
                            decoration: const InputDecoration(
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                            ),
                            cursorHeight: 15,
                            invalidNumberMessage: "الرقم غير صالح",
                            languageCode: "ar",
                            onChanged: (value) {
                              setState(() {
                                phoneNumberController = value.completeNumber;
                              });
                            },
                          ),
                        ),
                        // child: InputWidget(
                        //   label: "رقم الهاتف",
                        //   // maxLength: 8,
                        //   controller: phoneNumberController,
                        //   hint: "رقم الهاتف",
                        //   icon: Iconsax.call,
                        //   keyboardType: TextInputType.phone,
                        //   suffixIcon: IntlPhoneField(),
                        // ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      // Date of Birth
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: AppColors.whiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.black.withOpacity(.3),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 13.0),
                        ),
                        onPressed: () async {
                          // Set default values based on competition data
                          if (provider.competition!.adultNumber == 200) {
                            // ضبط التاريخ لتحديد الصغار فقط
                            initialDate = DateTime(DateTime.now().year - 6);
                            lastDate = DateTime(DateTime.now().year - 13);
                          } else if (provider.competition!.childNumber == 50) {
                            // ضبط التاريخ لتحديد الكبار فقط
                            initialDate = DateTime(DateTime.now().year - 13);
                            lastDate = DateTime(1970);
                          } else {
                            // السماح للجميع بالتسجيل
                            initialDate = DateTime(1970);
                            lastDate = DateTime(DateTime.now().year - 6);
                          }

                          // التأكد من أن initialDate ليس بعد lastDate
                          if (initialDate.isAfter(lastDate)) {
                            final temp = initialDate;
                            initialDate = lastDate;
                            lastDate = temp;
                          }

                          // استدعاء DatePicker
                          final DateTime? pickedDate = await showDatePicker(
                            initialEntryMode: DatePickerEntryMode.calendar,
                            context: context,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context)
                                    .copyWith(canvasColor: Colors.white),
                                child: child!,
                              );
                            },
                            initialDate: initialDate,
                            firstDate: initialDate,
                            lastDate: lastDate,
                          );

                          // تحديث التاريخ المختار وحساب نوع المسابقة
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              int age =
                                  DateTime.now().year - _selectedDate.year;
                              if (age >= 6 && age < 13) {
                                typecomp =
                                    "فئة الصغار"; // Category for children
                              } else if (age >= 13) {
                                typecomp = "فئة الكبار"; // Category for adults
                              }
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Iconsax.calendar,
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              DateFormat().add_yMd().format(_selectedDate),
                              style:
                                  const TextStyle(color: AppColors.blackColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  // مكان الإقامة الحالية
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("مكان الإقامة الحالية"),
                      Text(
                        typecomp,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('داخل موريتانيا'),
                          leading: Radio<String>(
                            value: 'داخل موريتانيا',
                            groupValue: selectedResudence,
                            onChanged: handleSelectedResudence,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('خارج موريتانيا'),
                          leading: Radio<String>(
                            value: 'خارج موريتانيا',
                            groupValue: selectedResudence,
                            onChanged: handleSelectedResudence,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),

                  // كم تحفظ من القرآن الكريم ؟
                  const Text("كم تحفظ من القرآن الكريم ؟"),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: DropdownButton<String>(
                      items: howMuchYouMemorizes.map((String text) {
                        return DropdownMenuItem<String>(
                          value: text,
                          child: Text(text.toString()),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          howMuchYouMemorize = value!;
                        });
                      },
                      hint: Text(
                        'Select an address',
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                          fontSize: 14.0,
                        ),
                      ),
                      value: howMuchYouMemorize,
                      isExpanded: true,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                      ),
                      icon: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Iconsax.arrow_down_14),
                      ),
                      underline: Container(),
                      elevation: 0,
                      dropdownColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      focusColor: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      autofocus: false,
                    ),
                  ),

                  const SizedBox(
                    height: 10.0,
                  ),
                  // هل حصلت على إجازة ؟
                  const Text("هل حصلت على إجازة ؟"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('نعم'),
                          leading: Radio<String>(
                            value: 'نعم',
                            groupValue: haveYouIhaza,
                            onChanged: handleHaveYouIhaza,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('لا'),
                          leading: Radio<String>(
                            value: 'لا',
                            groupValue: haveYouIhaza,
                            onChanged: handleHaveYouIhaza,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // كم رواية تقرأ بها ؟
                  const Text("كم رواية تقرأ بها ؟"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('رواية واحدة'),
                          leading: Radio<String>(
                            value: 'رواية واحدة',
                            groupValue: howMuchRiwayaYouHave,
                            onChanged: handleHowMuchRiwayaYouHave,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('أكثر من رواية'),
                          leading: Radio<String>(
                            value: 'أكثر من رواية',
                            groupValue: howMuchRiwayaYouHave,
                            onChanged: handleHowMuchRiwayaYouHave,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  // هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية ؟
                  const Text(
                      "هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية ؟"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('نعم'),
                          leading: Radio<String>(
                            value: 'نعم',
                            groupValue: haveYouParticipatedInACompetition,
                            onChanged: handleHaveYouParticipatedInACompetition,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('لا'),
                          leading: Radio<String>(
                            value: 'لا',
                            groupValue: haveYouParticipatedInACompetition,
                            onChanged: handleHaveYouParticipatedInACompetition,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى ؟
                  const Text(
                      "هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى ؟"),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('نعم'),
                          leading: Radio<String>(
                            value: 'نعم',
                            groupValue: haveYouEverWon1stTo2ndPlace,
                            onChanged: handleHaveYouEverWon1stTo2ndPlace,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('لا'),
                          leading: Radio<String>(
                            value: 'لا',
                            groupValue: haveYouEverWon1stTo2ndPlace,
                            onChanged: handleHaveYouEverWon1stTo2ndPlace,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.whiteColor,
                      backgroundColor: AppColors.primaryColor,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: Colors.black.withOpacity(.3),
                        width: 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 13.0),
                    ),
                    onPressed: () async {
                      if (!_fromKey.currentState!.validate()) {
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      Inscription inscription = Inscription(
                        fullName: fullNameController.text,
                        phoneNumber: phoneNumberController,
                        birthDate: _selectedDate,
                        residencePlace: selectedResudence,
                        howMuchYouMemorize: howMuchYouMemorize,
                        haveYouIhaza: haveYouIhaza,
                        howMuchRiwayaYouHave: howMuchRiwayaYouHave,
                        haveYouParticipatedInACompetition:
                            haveYouParticipatedInACompetition,
                        haveYouEverWon1stTo2ndPlace:
                            haveYouEverWon1stTo2ndPlace,
                        resultFirstRound: 0,
                        resultLastRound: 0,
                        isPassedFirstRound: false,
                      );

                      // String competitionVirsion = context
                      //     .read<CompetitionProvider>()
                      //     .competition!
                      //     .competitionVirsion
                      //     .toString();
                      bool isCreated = await InscriptionService.sendToFirebase(
                        inscription,
                        context,
                        provider.competition!,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      if (isCreated) {
                        fullNameController.clear();
                        // Navigator.pop(context);
                        // Navigator.pushAndRemoveUntil(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const HomeScreen(),
                        //   ),
                        //   (route) => false,
                        // );
                      }

                      // showDialog(
                      //   context: context,
                      //   builder: (BuildContext context) {
                      //     return AlertDialog(
                      //       title: const Text("تأكيد الرقم"),
                      //       content: Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           const Text(
                      //             "هل هذا هو رقمك الصحيح؟",
                      //             style: TextStyle(fontSize: 16),
                      //           ),
                      //           const SizedBox(height: 16),
                      //           Text(
                      //             phoneNumberController.text,
                      //             style: const TextStyle(
                      //                 fontSize: 18,
                      //                 fontWeight: FontWeight.bold,
                      //                 color: Colors.blueAccent),
                      //           ),
                      //           const SizedBox(height: 16),
                      //           const Text(
                      //             "سوف نرسل لك رمز تأكيد إلى هذا الرقم.",
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ],
                      //       ),
                      //       actions: [
                      //         TextButton(
                      //           child: const Text("تعديل",
                      //               style: TextStyle(color: Colors.blue)),
                      //           onPressed: () {
                      //             Navigator.of(context)
                      //                 .pop(); // Close the dialog without confirming
                      //           },
                      //         ),
                      //         TextButton(
                      //           child: const Text("تأكيد",
                      //               style: TextStyle(color: Colors.green)),
                      //           onPressed: () async {
                      //             Navigator.of(context).pop(); // Close the dialog
                      //             bool isSent =
                      //                 await AuthService.sendVerificationCode(
                      //                     phoneNumber: inscription.phoneNumber!,
                      //                     context: context);
                      //             if (isSent) {
                      //               Navigator.push(
                      //                 context,
                      //                 MaterialPageRoute(
                      //                   builder: (context) =>
                      //                       VerifyPhoneNumberScreen(
                      //                     inscription: inscription,
                      //                     function: () async {
                      //                       bool isCreated =
                      //                           await InscriptionService
                      //                               .sendToFirebase(
                      //                         inscription,
                      //                         context,
                      //                         competitionVirsion,
                      //                       );
                      //                       if (isCreated) {
                      //                         Navigator.pop(context);
                      //                         Navigator.pushAndRemoveUntil(
                      //                           context,
                      //                           MaterialPageRoute(
                      //                             builder: (context) =>
                      //                                 const HomeScreen(),
                      //                           ),
                      //                           (route) => false,
                      //                         );
                      //                       } else {
                      //                         Navigator.pop(context);
                      //                       }
                      //                     },
                      //                   ),
                      //                 ),
                      //               );
                      //             }
                      //           },
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // );

                      // Save user information to Firebase
                      // InscriptionService.sendToFirebase(
                      //   inscription,
                      //   context,
                      //   competitionVirsion,
                      // ).whenComplete(
                      //   () {
                      //     fullNameController.clear();
                      //     phoneNumberController.clear();
                      //     setState(() {
                      //       isLoading = false;
                      //     });
                      //   },
                      // );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         VerifyPhoneNumberScreen(inscription: inscription),
                      //   ),
                      // );
                    },
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.whiteColor,
                            strokeWidth: 2.0,
                          )
                        : const Text("إرسال المعلومات"),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
