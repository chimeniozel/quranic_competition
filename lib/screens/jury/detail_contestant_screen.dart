import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/widgets/input_widget.dart';

class DetailContestantScreen extends StatefulWidget {
  final Inscription inscription;
  final String competitionType;
  final String competitionVersion;
  const DetailContestantScreen({
    super.key,
    required this.inscription,
    required this.competitionType,
    required this.competitionVersion,
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
        widget.inscription.noteTajwid![authProvider.currentUser!.fullName] !=
            null &&
        widget.inscription
                .noteHousnSawtt![authProvider.currentUser!.fullName] !=
            null &&
        widget.inscription
                .noteIltizamRiwaya![authProvider.currentUser!.fullName] !=
            null) {
      noteTajwidController.text = widget
          .inscription.noteTajwid![authProvider.currentUser!.fullName]
          .toString();
      noteHousnSawttController.text = widget
          .inscription.noteHousnSawtt![authProvider.currentUser!.fullName]
          .toString();
      noteIltizamRiwayaController.text = widget
          .inscription.noteIltizamRiwaya![authProvider.currentUser!.fullName]
          .toString();
    }
    if (widget.competitionType != "adult_inscription" &&
        widget.inscription.noteTajwid![authProvider.currentUser!.fullName] !=
            null &&
        widget.inscription
                .noteHousnSawtt![authProvider.currentUser!.fullName] !=
            null &&
        widget.inscription
                .noteOu4oubetSawtt![authProvider.currentUser!.fullName] !=
            null &&
        widget.inscription
                .noteWaqfAndIbtidaa![authProvider.currentUser!.fullName] !=
            null) {
      noteTajwidController.text = widget
          .inscription.noteTajwid![authProvider.currentUser!.fullName]
          .toString();
      noteHousnSawttController.text = widget
          .inscription.noteHousnSawtt![authProvider.currentUser!.fullName]
          .toString();
      noteOu4oubetSawttController.text = widget
          .inscription.noteOu4oubetSawtt![authProvider.currentUser!.fullName]
          .toString();
      noteWaqfAndIbtidaaController.text = widget
          .inscription.noteWaqfAndIbtidaa![authProvider.currentUser!.fullName]
          .toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Inscription inscription = widget.inscription;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("المتسابق رقم : ${inscription.idInscription}"),
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
                    inscription.noteTajwid![fullName] =
                        int.parse(noteTajwidController.text);
                    inscription.noteHousnSawtt![fullName] =
                        int.parse(noteHousnSawttController.text);
                    inscription.noteIltizamRiwaya![fullName] =
                        int.parse(noteIltizamRiwayaController.text);
                    AuthService.updateContestant(context, fullName, inscription,
                        widget.competitionVersion, widget.competitionType);
                  } else {
                    inscription.noteTajwid![fullName] =
                        int.parse(noteTajwidController.text);
                    inscription.noteHousnSawtt![fullName] =
                        int.parse(noteHousnSawttController.text);
                    inscription.noteOu4oubetSawtt![fullName] =
                        int.parse(noteOu4oubetSawttController.text);
                    inscription.noteWaqfAndIbtidaa![fullName] =
                        int.parse(noteWaqfAndIbtidaaController.text);
                    AuthService.updateContestant(context, fullName, inscription,
                        widget.competitionVersion, widget.competitionType);
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
