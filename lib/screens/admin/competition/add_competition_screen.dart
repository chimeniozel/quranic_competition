import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class AddCompetitionScreen extends StatefulWidget {
  final Competition? competition;
  const AddCompetitionScreen({super.key, this.competition});

  @override
  State<AddCompetitionScreen> createState() => _AddCompetitionScreenState();
}

class _AddCompetitionScreenState extends State<AddCompetitionScreen> {
  TextEditingController competitionVirsionController = TextEditingController();
  TextEditingController successMoyenneChildController = TextEditingController();
  TextEditingController successMoyenneAdultController = TextEditingController();
  TextEditingController maxAdultController = TextEditingController();
  TextEditingController maxChildController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now().add(const Duration(days: 1));
  String openInscription = "نعم";

  // Date picker for start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendar,
      context: context,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.white),
          child: child!,
        );
      },
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _saveCompetition() async {
    if (!_formKey.currentState!.validate()) {
      // Validation failed
      return;
    }
    if (widget.competition == null) {
      String competitionVersion = competitionVirsionController.text.trim();

      if (competitionVersion.isNotEmpty) {
        bool hasActiveCompetition =
            await CompetitionService.hasActiveCompetition();

        if (hasActiveCompetition) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('لا يمكن إنشاء نسخة جديدة أثناء وجود نسخة نشطة حالياً'),
              backgroundColor: AppColors.yellowColor,
            ),
          );
          return;
        }

        bool isActive = DateTime.now().isAfter(selectedStartDate) &&
            DateTime.now().isBefore(selectedEndDate);

        Competition competition = Competition(
          competitionVirsion: competitionVersion,
          startDate: selectedStartDate,
          successMoyenneChild: double.parse(successMoyenneChildController.text),
          successMoyenneAdult: double.parse(successMoyenneAdultController.text),
          adultNumberMax: int.parse(maxAdultController.text),
          childNumberMax: int.parse(maxChildController.text),
          isActive: isActive,
          firstRoundIsPublished: false,
          lastRoundIsPublished: false,
          adultNumber: 0,
          childNumber: 0,
          isInscriptionOpen: true,
          competitionTypes: ["child_inscription", "adult_inscription"],
          archiveEntry: ArchiveEntry(imagesURL: [], videosURL: []),
        );

        await FirebaseFirestore.instance
            .collection('competitions')
            .add(competition.toMap())
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('competitions')
              .doc(value.id)
              .update({
            'competitionId': value.id,
          });
        });

        competitionVirsionController.clear();
        setState(() {
          selectedStartDate = DateTime.now();
          selectedEndDate = DateTime.now().add(const Duration(days: 1));
          successMoyenneChildController.clear();
          successMoyenneAdultController.clear();
        });
      }
    } else {
      if (widget.competition!.isInscriptionOpen == true &&
          widget.competition!.firstRoundIsPublished == false) {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competition!.competitionId!)
            .update({
          "adultNumberMax": int.parse(maxAdultController.text),
          "childNumberMax": int.parse(maxChildController.text),
          "isInscriptionOpen": true,
        }).whenComplete(() {
          final failureSnackBar = SnackBar(
            content: const Text("تم التعديل بنجاح !"),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {},
            ),
            backgroundColor: AppColors.greenColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
        });
      } else {
        await FirebaseFirestore.instance
            .collection('competitions')
            .doc(widget.competition!.competitionId!)
            .update({
          "adultNumberMax": int.parse(maxAdultController.text),
          "childNumberMax": int.parse(maxChildController.text),
        }).whenComplete(() {
          final failureSnackBar = SnackBar(
            content: const Text("تم التعديل بنجاح !"),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {},
            ),
            backgroundColor: AppColors.greenColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
        });
      }
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void handleOpenInscription(String? value) {
    setState(() {
      openInscription = value!;
      widget.competition!.isInscriptionOpen = true;
    });
    print(
        "======================================== is open : ${widget.competition!.isInscriptionOpen}");
  }

  @override
  void initState() {
    if (widget.competition != null) {
      maxAdultController.text = widget.competition!.adultNumberMax.toString();
      maxChildController.text = widget.competition!.childNumberMax.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(widget.competition != null ? 'تعديل النسخة' : 'إضافة نسخة'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            8.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                if (widget.competition == null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputWidget(
                        keyboardType: TextInputType.number,
                        label: "معدل الكبار",
                        controller: successMoyenneAdultController,
                        hint: "85.5",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الحقل فارغ";
                          }
                          try {
                            double parsedValue = double.parse(
                                value); // Try to parse the value to a double
                            if (parsedValue > 100) {
                              return "القيمة يجب أن تكون أقل من أو تساوي 100";
                            }
                          } catch (e) {
                            return "الرجاء إدخال قيمة رقمية صحيحة";
                          }
                          return null; // Validation passed
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InputWidget(
                        label: "اسم النسخة",
                        controller: competitionVirsionController,
                        hint: "اسم النسخة",
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InputWidget(
                        keyboardType: TextInputType.number,
                        label: "معدل الصغار",
                        controller: successMoyenneChildController,
                        hint: "14.5",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الحقل فارغ";
                          }
                          try {
                            double parsedValue = double.parse(
                                value); // Try to parse the value to a double
                            if (parsedValue > 20) {
                              return "القيمة يجب أن تكون أقل من أو تساوي 20";
                            }
                          } catch (e) {
                            return "الرجاء إدخال قيمة رقمية صحيحة";
                          }
                          return null; // Validation passed
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      InputWidget(
                        keyboardType: TextInputType.number,
                        label: "معدل الكبار",
                        controller: successMoyenneAdultController,
                        hint: "85.5",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "الحقل فارغ";
                          }
                          try {
                            double parsedValue = double.parse(
                                value); // Try to parse the value to a double
                            if (parsedValue > 100) {
                              return "القيمة يجب أن تكون أقل من أو تساوي 100";
                            }
                          } catch (e) {
                            return "الرجاء إدخال قيمة رقمية صحيحة";
                          }
                          return null; // Validation passed
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                InputWidget(
                  keyboardType: TextInputType.number,
                  label: "الحد الأقصى للكبار",
                  controller: maxAdultController,
                  hint: "الحد الأقصى للكبار",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الحقل فارغ";
                    }
                    try {
                      double.parse(value); // Try to parse the value to a double
                    } catch (e) {
                      return "الرجاء إدخال قيمة رقمية صحيحة";
                    }
                    return null; // Validation passed
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                InputWidget(
                  keyboardType: TextInputType.number,
                  label: "الحد الأقصى للصغار",
                  controller: maxChildController,
                  hint: "الحد الأقصى للصغار",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الحقل فارغ";
                    }
                    try {
                      double.parse(value);
                    } catch (e) {
                      return "الرجاء إدخال قيمة رقمية صحيحة";
                    }
                    return null; // Validation passed
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                if (widget.competition != null &&
                    widget.competition!.isInscriptionOpen! == false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("هل تريد إعادة فتح التسجيل في هذه النسخة ؟"),
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text(
                                'نعم',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              leading: Radio<String>(
                                value: 'نعم',
                                groupValue: openInscription,
                                onChanged: handleOpenInscription,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text(
                                'لا',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                              leading: Radio<String>(
                                value: 'لا',
                                groupValue: openInscription,
                                onChanged: handleOpenInscription,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    minimumSize: const Size(double.infinity, 45.0),
                  ),
                  onPressed: _saveCompetition,
                  child: const Text(
                    'حفظ',
                    style: TextStyle(color: AppColors.whiteColor),
                  ),
                ),
                const SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
