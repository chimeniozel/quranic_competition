import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class DetailContestantScreen extends StatefulWidget {
  final Inscription? inscription;
  final NoteResult? noteResult;
  final String competitionType;
  final String competitionVersion;
  final String competitionRound;
  const DetailContestantScreen({
    super.key,
    required this.inscription,
    required this.noteResult,
    required this.competitionType,
    required this.competitionVersion,
    required this.competitionRound,
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
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    if (widget.competitionType == "adult_inscription" &&
        widget.noteResult?.notes?.noteTajwid != null &&
        widget.noteResult?.notes?.noteHousnSawtt != null &&
        widget.noteResult?.notes?.noteIltizamRiwaya != null) {
      noteTajwidController.text =
          widget.noteResult!.notes!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.noteResult!.notes!.noteHousnSawtt!.toString();
      noteIltizamRiwayaController.text =
          widget.noteResult!.notes!.noteIltizamRiwaya!.toString();
    }
    if (widget.competitionType != "adult_inscription") {
      noteTajwidController.text =
          widget.noteResult!.notes!.noteTajwid!.toString();
      noteHousnSawttController.text =
          widget.noteResult!.notes!.noteHousnSawtt!.toString();
      noteOu4oubetSawttController.text =
          widget.noteResult!.notes!.noteOu4oubetSawtt!.toString();
      noteWaqfAndIbtidaaController.text =
          widget.noteResult!.notes!.noteWaqfAndIbtidaa!.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NoteResult? noteResult = widget.noteResult!;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("المتسابق رقم : ${widget.inscription!.idInscription}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InputWidget(
                  keyboardType: TextInputType.number,
                  label: "التجويد",
                  controller: noteTajwidController,
                  hint: "التجويد"),
              const SizedBox(
                height: 15.0,
              ),
              InputWidget(
                  keyboardType: TextInputType.number,
                  label: "حسن الصوت",
                  controller: noteHousnSawttController,
                  hint: "حسن الصوت"),
              const SizedBox(
                height: 15.0,
              ),
              widget.competitionType == "adult_inscription"
                  ? InputWidget(
                      keyboardType: TextInputType.number,
                      label: "الإلتزام بالرواية",
                      controller: noteIltizamRiwayaController,
                      hint: "الإلتزام بالرواية")
                  : Column(
                      children: [
                        InputWidget(
                            keyboardType: TextInputType.number,
                            label: "عذوبة الصوت",
                            controller: noteOu4oubetSawttController,
                            hint: "عذوبة الصوت"),
                        const SizedBox(
                          height: 15.0,
                        ),
                        InputWidget(
                            keyboardType: TextInputType.number,
                            label: "الوقف والإبتداء",
                            controller: noteWaqfAndIbtidaaController,
                            hint: "الوقف والإبتداء"),
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
                  setState(() {
                    isLoading = true;
                  });
                  String fullName = authProvider.currentUser!.fullName;

                  if (widget.competitionType == "adult_inscription") {
                    noteResult.notes?.noteTajwid =
                        double.parse(noteTajwidController.text);
                    noteResult.notes?.noteHousnSawtt =
                        double.parse(noteHousnSawttController.text);
                    noteResult.notes?.noteIltizamRiwaya =
                        double.parse(noteIltizamRiwayaController.text);
                    noteResult.notes?.result =
                        double.parse(noteTajwidController.text) +
                            double.parse(noteHousnSawttController.text) +
                            double.parse(noteIltizamRiwayaController.text);
                    noteResult.isCorrected = true;
                    AuthService.updateContestant(
                        context,
                        fullName,
                        noteResult,
                        widget.inscription!,
                        widget.competitionVersion,
                        widget.competitionType,
                        widget.competitionRound);
                  } else {
                    noteResult.notes?.noteTajwid =
                        double.parse(noteTajwidController.text);
                    noteResult.notes?.noteHousnSawtt =
                        double.parse(noteHousnSawttController.text);
                    noteResult.notes?.noteOu4oubetSawtt =
                        double.parse(noteOu4oubetSawttController.text);
                    noteResult.notes?.noteWaqfAndIbtidaa =
                        double.parse(noteWaqfAndIbtidaaController.text);
                    noteResult.notes?.result =
                        double.parse(noteTajwidController.text) +
                            double.parse(noteHousnSawttController.text) +
                            double.parse(noteOu4oubetSawttController.text) +
                            double.parse(noteWaqfAndIbtidaaController.text);
                    noteResult.isCorrected = true;
                    AuthService.updateContestant(
                        context,
                        fullName,
                        noteResult,
                        widget.inscription!,
                        widget.competitionVersion,
                        widget.competitionType,
                        widget.competitionRound);
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
    );
  }
}
