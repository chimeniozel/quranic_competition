import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
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
  final TextEditingController phoneNumberController = TextEditingController();
  String selectedResudence = "داخل موريتانيا";
  String howMuchYouMemorize = "القرآن كاملا";
  String haveYouIhaza = "نعم";
  String howMuchRiwayaYouHave = "رواية واحدة";
  String haveYouParticipatedInACompetition = "نعم";
  String haveYouEverWon1stTo2ndPlace = "نعم";
  bool obscure = true;
  DateTime _selectedDate = DateTime(DateTime.now().year - 6);

  List<String> howMuchYouMemorizes = ["القرآن كاملا", "نصف", "أقل من نصف"];

  bool isLoading = false;

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendar,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: child!,
        );
      },
      initialDate: DateTime(DateTime.now().year - 6),
      firstDate: DateTime(1900),
      lastDate: DateTime(DateTime.now().year - 6),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        if (DateTime.now().year - _selectedDate.year >= 6 &&
            DateTime.now().year - _selectedDate.year < 13) {
          typecomp = "فئة الصغار";
        }
        if (DateTime.now().year - _selectedDate.year >= 13) {
          typecomp = "فئة الكبار";
        }
      });
    }
  }

  final _fromKey = GlobalKey<FormState>();

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
      body: SingleChildScrollView(
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
                      child: InputWidget(
                        label: "رقم الهاتف",
                        maxLength: 8,
                        controller: phoneNumberController,
                        hint: "رقم الهاتف",
                        icon: Iconsax.call,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    // Date of Birth
                    Expanded(
                      child: ElevatedButton(
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
                        onPressed: () => _selectDate(context),
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
                    List<Map<String, dynamic>> round = [];
                    setState(() {
                      isLoading = true;
                    });
                    if (DateTime.now().year - _selectedDate.year < 13) {
                      for (var user
                          in Provider.of<AuthProvider>(context, listen: false)
                              .users!) {
                        NoteModel notes = NoteModel(
                          noteHousnSawtt: 0,
                          noteIltizamRiwaya: 0,
                          noteOu4oubetSawtt: 0,
                          noteTajwid: 0,
                          noteWaqfAndIbtidaa: 0,
                          result: 0,
                        );
                        NoteResult noteResult = NoteResult(
                          cheikhName: user.fullName,
                          notes: notes,
                          isCorrected: false,
                        );
                        round.add(noteResult.toMapChild()!);
                      }
                    } else {
                      for (var user
                          in Provider.of<AuthProvider>(context, listen: false)
                              .users!) {
                        NoteModel notes = NoteModel(
                          noteHousnSawtt: 0,
                          noteIltizamRiwaya: 0,
                          noteOu4oubetSawtt: 0,
                          noteTajwid: 0,
                          noteWaqfAndIbtidaa: 0,
                          result: 0,
                        );
                        NoteResult noteResult = NoteResult(
                          cheikhName: user.fullName,
                          notes: notes,
                          isCorrected: false,
                        );
                        round.add(noteResult.toMapAdult()!);
                      }
                    }

                    TashihMachaikhs tashihMachaikhs = TashihMachaikhs(
                      firstRound: round,
                      finalRound: round,
                    );
                    Inscription inscription = Inscription(
                      fullName: fullNameController.text,
                      phoneNumber: phoneNumberController.text,
                      birthDate: _selectedDate,
                      residencePlace: selectedResudence,
                      howMuchYouMemorize: howMuchYouMemorize,
                      haveYouIhaza: haveYouIhaza,
                      howMuchRiwayaYouHave: howMuchRiwayaYouHave,
                      haveYouParticipatedInACompetition:
                          haveYouParticipatedInACompetition,
                      haveYouEverWon1stTo2ndPlace: haveYouEverWon1stTo2ndPlace,
                      tashihMachaikhs: tashihMachaikhs,
                      resultFirstRound: 0,
                      resultLastRound: 0,
                      isPassedFirstRound: false,
                    );

                    String competitionVirsion = context
                        .read<CompetitionProvider>()
                        .competition!
                        .competitionVirsion
                        .toString();

                    // Save user information to Firebase
                    InscriptionService.sendToFirebase(
                      inscription,
                      context,
                      competitionVirsion,
                    ).whenComplete(
                      () {
                        fullNameController.clear();
                        phoneNumberController.clear();
                        setState(() {
                          isLoading = false;
                        });
                      },
                    );
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.whiteColor,
                        )
                      : const Text("إرسال المعلومات"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
