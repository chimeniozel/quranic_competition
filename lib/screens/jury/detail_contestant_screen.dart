import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/note_model.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/jury/jury_home_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class DetailContestantScreen extends StatefulWidget {
  final Inscription? inscription;
  final NoteModel? noteModel;
  final String competitionType;
  final String competitionVersion;
  final String competitionRound;
  const DetailContestantScreen({
    super.key,
    required this.inscription,
    required this.competitionType,
    required this.competitionVersion,
    required this.competitionRound,
    required this.noteModel,
  });

  @override
  State<DetailContestantScreen> createState() => _DetailContestantScreenState();
}

class _DetailContestantScreenState extends State<DetailContestantScreen> {
  TextEditingController noteTajwidController = TextEditingController();
  TextEditingController noteHousnSawttController = TextEditingController();
  TextEditingController noteIltizamRiwayaController = TextEditingController();
  TextEditingController noteOu4oubetSawttController = TextEditingController();
  TextEditingController noteWaqfAndIbtidaaController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    if (widget.competitionType == "child_inscription" &&
        widget.noteModel?.noteTajwid != null &&
        widget.noteModel?.noteHousnSawtt != null &&
        widget.noteModel?.noteIltizamRiwaya != null) {
      noteTajwidController.text = widget.noteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.noteModel!.noteHousnSawtt!.toString();
      noteIltizamRiwayaController.text =
          widget.noteModel!.noteIltizamRiwaya!.toString();
    }
    if (widget.competitionType == "adult_inscription" &&
        widget.noteModel?.noteTajwid != null &&
        widget.noteModel?.noteHousnSawtt != null &&
        widget.noteModel?.noteOu4oubetSawtt != null &&
        widget.noteModel?.noteWaqfAndIbtidaa != null) {
      noteTajwidController.text = widget.noteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.noteModel!.noteHousnSawtt!.toString();
      noteOu4oubetSawttController.text =
          widget.noteModel!.noteOu4oubetSawtt!.toString();
      noteWaqfAndIbtidaaController.text =
          widget.noteModel!.noteWaqfAndIbtidaa!.toString();
    }

    super.initState();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AuthProviders authProviders =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text("المتسابق رقم : ${widget.inscription!.idInscription}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputWidget(
                keyboardType: TextInputType.number,
                label: "التجويد",
                controller: noteTajwidController,
                hint: "التجويد",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الحقل فارغ";
                  }
                  try {
                    double parsedValue = double.parse(value);
                    if (widget.competitionType == "adult_inscription" &&
                        parsedValue > 70) {
                      return "القيمة يجب أن تكون أقل من أو تساوي 70";
                    }
                    if (widget.competitionType != "adult_inscription" &&
                        parsedValue > 15) {
                      return "القيمة يجب أن تكون أقل من أو تساوي 15";
                    }
                  } catch (e) {
                    return "الرجاء إدخال قيمة رقمية صحيحة";
                  }
                  return null; // No validation errors
                },
              ),
              const SizedBox(
                height: 15.0,
              ),
              InputWidget(
                keyboardType: TextInputType.number,
                label: "حسن الصوت",
                controller: noteHousnSawttController,
                hint: "حسن الصوت",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الحقل فارغ";
                  }
                  try {
                    double parsedValue = double.parse(
                        value); // Try to parse the value to a double
                    if (widget.competitionType == "adult_inscription") {
                      if (parsedValue > 5) {
                        return "القيمة يجب أن تكون أقل من أو تساوي 5";
                      }
                    } else {
                      if (parsedValue > 3) {
                        return "القيمة يجب أن تكون أقل من أو تساوي 3";
                      }
                    }
                  } catch (e) {
                    return "الرجاء إدخال قيمة رقمية صحيحة";
                  }
                  return null; // Validation passed
                },
              ),
              const SizedBox(
                height: 15.0,
              ),
              widget.competitionType == "child_inscription"
                  ? InputWidget(
                      keyboardType: TextInputType.number,
                      label: "الإلتزام بالرواية",
                      controller: noteIltizamRiwayaController,
                      hint: "الإلتزام بالرواية",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "الحقل فارغ";
                        }
                        try {
                          double parsedValue = double.parse(
                              value); // Try to parse the value to a double
                          if (parsedValue > 2) {
                            return "القيمة يجب أن تكون أقل من أو تساوي 2";
                          }
                        } catch (e) {
                          return "الرجاء إدخال قيمة رقمية صحيحة";
                        }
                        return null; // Validation passed
                      },
                    )
                  : Column(
                      children: [
                        InputWidget(
                          keyboardType: TextInputType.number,
                          label: "عذوبة الصوت",
                          controller: noteOu4oubetSawttController,
                          hint: "عذوبة الصوت",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الحقل فارغ";
                            }
                            try {
                              double parsedValue = double.parse(
                                  value); // Try to parse the value to a double
                              if (parsedValue > 5) {
                                return "القيمة يجب أن تكون أقل من أو تساوي 5";
                              }
                            } catch (e) {
                              return "الرجاء إدخال قيمة رقمية صحيحة";
                            }
                            return null; // Validation passed
                          },
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        InputWidget(
                          keyboardType: TextInputType.number,
                          label: "الوقف والإبتداء",
                          controller: noteWaqfAndIbtidaaController,
                          hint: "الوقف والإبتداء",
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
                      ],
                    ),
              const SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: const Size(double.infinity, 40.0),
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) {
                    // Validation failed
                    return;
                  }
                  setState(() {
                    isLoading = true;
                  });
                  JuryInscription juryInscription;
                  NoteModel noteModel = NoteModel();
                  if (widget.competitionType == "child_inscription") {
                    noteModel.noteTajwid =
                        double.parse(noteTajwidController.text);
                    noteModel.noteHousnSawtt =
                        double.parse(noteHousnSawttController.text);
                    noteModel.noteIltizamRiwaya =
                        double.parse(noteIltizamRiwayaController.text);
                    noteModel.result = double.parse(noteTajwidController.text) +
                        double.parse(noteHousnSawttController.text) +
                        double.parse(noteIltizamRiwayaController.text);
                    if (widget.competitionRound == "التصفيات الأولى") {
                      juryInscription = JuryInscription(
                        idJury: authProviders.currentJury!.userID!,
                        idInscription: widget.inscription!.idInscription!,
                        firstNotes: noteModel,
                        lastNotes: NoteModel(
                          noteTajwid: 0,
                          noteHousnSawtt: 0,
                          noteIltizamRiwaya: 0,
                          noteOu4oubetSawtt: 0,
                          noteWaqfAndIbtidaa: 0,
                          result: 0,
                        ),
                        isAdult: false,
                        isFirstCorrected: true,
                        isLastCorrected: false,
                      );
                    } else {
                      juryInscription = JuryInscription(
                        idJury: authProviders.currentJury!.userID!,
                        idInscription: widget.inscription!.idInscription!,
                        lastNotes: noteModel,
                        isAdult: false,
                        isLastCorrected: true,
                      );
                    }

                    // update inscription is corrected for first round and last round
                    AuthService.addJuryInscriptionNotes(
                      competitionVersion: widget.competitionVersion,
                      juryInscription: juryInscription,
                      isAdult: false,
                      context: context,
                      competitionRound: widget.competitionRound,
                    );
                  } else {
                    noteModel.noteTajwid =
                        double.parse(noteTajwidController.text);
                    noteModel.noteHousnSawtt =
                        double.parse(noteHousnSawttController.text);
                    noteModel.noteOu4oubetSawtt =
                        double.parse(noteOu4oubetSawttController.text);
                    noteModel.noteWaqfAndIbtidaa =
                        double.parse(noteWaqfAndIbtidaaController.text);
                    noteModel.result = double.parse(noteTajwidController.text) +
                        double.parse(noteHousnSawttController.text) +
                        double.parse(noteOu4oubetSawttController.text) +
                        double.parse(noteWaqfAndIbtidaaController.text);
                    if (widget.competitionRound == "التصفيات الأولى") {
                      juryInscription = JuryInscription(
                        idJury: authProviders.currentJury!.userID!,
                        idInscription: widget.inscription!.idInscription!,
                        firstNotes: noteModel,
                        lastNotes: NoteModel(
                          noteTajwid: 0,
                          noteHousnSawtt: 0,
                          noteIltizamRiwaya: 0,
                          noteOu4oubetSawtt: 0,
                          noteWaqfAndIbtidaa: 0,
                          result: 0,
                        ),
                        isAdult: true,
                        isFirstCorrected: true,
                        isLastCorrected: false,
                      );
                    } else {
                      juryInscription = JuryInscription(
                        idJury: authProviders.currentJury!.userID!,
                        idInscription: widget.inscription!.idInscription!,
                        lastNotes: noteModel,
                        isAdult: true,
                        isFirstCorrected: false,
                        isLastCorrected: true,
                      );
                    }
                    AuthService.addJuryInscriptionNotes(
                      competitionVersion: widget.competitionVersion,
                      juryInscription: juryInscription,
                      isAdult: true,
                      context: context,
                      competitionRound: widget.competitionRound,
                    );
                  }
                  // Navigate to the jury home screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JuryHomeScreen(
                        selectedType: juryInscription.isAdult!
                            ? "adult_inscription"
                            : "child_inscription",
                      ),
                    ),
                    (route) => false,
                  );

                  setState(() {
                    isLoading = false;
                  });
                },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.whiteColor,
                      )
                    : const Text(
                        "حفظ",
                        style: TextStyle(
                          color: AppColors.whiteColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
