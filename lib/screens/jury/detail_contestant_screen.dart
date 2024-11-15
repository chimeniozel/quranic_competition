import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/jury/jury_final_results.dart';
import 'package:quranic_competition/screens/jury/jury_home_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class DetailContestantScreen extends StatefulWidget {
  final Inscription? inscription;
  final NoteModel? firsNoteModel;
  final NoteModel? lastNoteModel;
  final String competitionType;
  final String competitionVersion;
  final String competitionRound;
  const DetailContestantScreen({
    super.key,
    required this.inscription,
    required this.competitionType,
    required this.competitionVersion,
    required this.competitionRound, required this.firsNoteModel, required this.lastNoteModel,
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
    if (widget.competitionRound == "التصفيات الأولى") {
      if (widget.competitionType == "adult_inscription" &&
        widget.firsNoteModel?.noteTajwid != null &&
        widget.firsNoteModel?.noteHousnSawtt != null &&
        widget.firsNoteModel?.noteIltizamRiwaya != null) {
      noteTajwidController.text = widget.firsNoteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.firsNoteModel!.noteHousnSawtt!.toString();
      noteIltizamRiwayaController.text =
          widget.firsNoteModel!.noteIltizamRiwaya!.toString();
    }
    if (widget.competitionType != "adult_inscription" &&
        widget.firsNoteModel?.noteTajwid != null &&
        widget.firsNoteModel?.noteHousnSawtt != null &&
        widget.firsNoteModel?.noteOu4oubetSawtt != null &&
        widget.firsNoteModel!.noteWaqfAndIbtidaa != null) {
      noteTajwidController.text = widget.firsNoteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.firsNoteModel!.noteHousnSawtt!.toString();
      noteOu4oubetSawttController.text =
          widget.firsNoteModel!.noteOu4oubetSawtt!.toString();
      noteWaqfAndIbtidaaController.text =
          widget.firsNoteModel!.noteWaqfAndIbtidaa!.toString();
    }
    } else {
      if (widget.competitionType == "adult_inscription" &&
        widget.lastNoteModel?.noteTajwid != null &&
        widget.lastNoteModel?.noteHousnSawtt != null &&
        widget.lastNoteModel?.noteIltizamRiwaya != null) {
      noteTajwidController.text = widget.lastNoteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.lastNoteModel!.noteHousnSawtt!.toString();
      noteIltizamRiwayaController.text =
          widget.lastNoteModel!.noteIltizamRiwaya!.toString();
    }
    if (widget.competitionType != "adult_inscription" &&
        widget.lastNoteModel?.noteTajwid != null &&
        widget.lastNoteModel?.noteHousnSawtt != null &&
        widget.lastNoteModel?.noteOu4oubetSawtt != null &&
        widget.lastNoteModel!.noteWaqfAndIbtidaa != null) {
      noteTajwidController.text = widget.lastNoteModel!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.lastNoteModel!.noteHousnSawtt!.toString();
      noteOu4oubetSawttController.text =
          widget.lastNoteModel!.noteOu4oubetSawtt!.toString();
      noteWaqfAndIbtidaaController.text =
          widget.lastNoteModel!.noteWaqfAndIbtidaa!.toString();
    }
    }
    super.initState();
  }

  final _fromKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AuthProviders authProviders =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("المتسابق رقم : ${widget.inscription!.idInscription}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: _fromKey,
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
                      double.parse(value); // Try to parse the value to a double
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
                  label: "حسن الصوت",
                  controller: noteHousnSawttController,
                  hint: "حسن الصوت",
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
                  height: 15.0,
                ),
                widget.competitionType == "adult_inscription"
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
                            double.parse(
                                value); // Try to parse the value to a double
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
                                double.parse(
                                    value); // Try to parse the value to a double
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
                                double.parse(
                                    value); // Try to parse the value to a double
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
                    if (!_fromKey.currentState!.validate()) {
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    JuryInscription juryInscription;
                    NoteModel noteModel = NoteModel();
                    if (widget.competitionType == "adult_inscription") {
                      noteModel.noteTajwid =
                          double.parse(noteTajwidController.text);
                      noteModel.noteHousnSawtt =
                          double.parse(noteHousnSawttController.text);
                      noteModel.noteIltizamRiwaya =
                          double.parse(noteIltizamRiwayaController.text);
                      noteModel.result =
                          double.parse(noteTajwidController.text) +
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
                          isAdult: true,
                          isFirstCorrected: true,
                          isLastCorrected: false,
                        );
                      } else {
                        print(
                            "========================= note : ${noteModel.toMapAdult()}");
                        juryInscription = JuryInscription(
                          idJury: authProviders.currentJury!.userID!,
                          idInscription: widget.inscription!.idInscription!,
                          lastNotes: noteModel,
                          isAdult: true,
                          isLastCorrected: true,
                        );
                      }

                      // update inscription is corrected for first round and last round
                      AuthService.addJuryInscriptionNotes(
                        competitionVersion: widget.competitionVersion,
                        juryInscription: juryInscription,
                        isAdult: true,
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
                      noteModel.result =
                          double.parse(noteTajwidController.text) +
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
                          isFirstCorrected: false,
                          isLastCorrected: true,
                        );
                      }
                      AuthService.addJuryInscriptionNotes(
                        competitionVersion: widget.competitionVersion,
                        juryInscription: juryInscription,
                        isAdult: false,
                        context: context,
                        competitionRound: widget.competitionRound,
                      );
                    }
                    if (widget.competitionRound == "التصفيات الأولى") {
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
                    } else {
                      // Navigate to the jury home screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JuryFinalResults(
                            selectedType: juryInscription.isAdult!
                                ? "adult_inscription"
                                : "child_inscription",
                          ),
                        ),
                        (route) => false,
                      );
                    }
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
      ),
    );
  }
}
