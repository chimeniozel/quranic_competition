import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart';

class AuthService {
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  static Future<void> verifyPhoneNumber(
      BuildContext context, String phoneNumber) async {
    return await Provider.of<AuthProvider>(context, listen: false)
        .verifyPhoneNumber(phoneNumber);
  }

  static Future<Users> getCurrentUser(String phoneNumber) async {
    var usersRef = firebaseFirestore.collection("users");
    var users = await usersRef.doc(phoneNumber).get();
    return Users.fromMap(users.data()!);
  }

  // Update a Contestant
  static Future<void> updateContestant(
      BuildContext context,
      String fullName,
      Inscription inscription,
      String competitionVersion,
      String competitionType) async {
    try {
      var usersRef = firebaseFirestore.collection("users");
      var cometitionTypeRef = firebaseFirestore
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection(competitionType)
          .doc(inscription.phoneNumber);

      if (competitionType == "adult_inscription") {
        var result = inscription.noteTajwid![fullName] +
            inscription.noteHousnSawtt![fullName] +
            inscription.noteIltizamRiwaya![fullName];

        await cometitionTypeRef.update({
          "التجويد.$fullName": inscription.noteTajwid![fullName],
          "حسن الصوت.$fullName": inscription.noteHousnSawtt![fullName],
          "الإلتزام بالرواية.$fullName":
              inscription.noteIltizamRiwaya![fullName],
          "المجموع.$fullName": result,
        });
      } else {
        var result = inscription.noteTajwid![fullName] +
            inscription.noteHousnSawtt![fullName] +
            inscription.noteOu4oubetSawtt![fullName] +
            inscription.noteWaqfAndIbtidaa![fullName];

        await cometitionTypeRef.update({
          "التجويد.$fullName": inscription.noteTajwid![fullName],
          "حسن الصوت.$fullName": inscription.noteHousnSawtt![fullName],
          "عذوبة الصوت.$fullName": inscription.noteOu4oubetSawtt![fullName],
          "الوقف والإبتداء.$fullName":
              inscription.noteWaqfAndIbtidaa![fullName],
          "المجموع.$fullName": result,
        });
      }

      // Snackbar for success
      final successSnackBar = SnackBar(
        content: const Text('تم حفظ العلامة بنجاح'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            // Perform some action
          },
        ),
        backgroundColor: AppColors.greenColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    } catch (e) {
      // Snackbar for exception
      final errorSnackBar = SnackBar(
        content: Text('حدث خطأ أثناء حفظ العلامة: $e'),
        action: SnackBarAction(
          label: 'حاول مرة أخرى',
          onPressed: () {
            // Optional: Retry the operation or other actions
          },
        ),
        backgroundColor: Colors
            .red, // Optional: Change the background color to red to indicate an error
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
  }

  // check if all constraints have notes and return result and list of constraints

  static Future<Map<String, dynamic>> checkAllNotes(
      String version, String cometionType, String fullName) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);

    QuerySnapshot querySnapshot = await inscriptionCollection
        .orderBy("رقم التسجيل", descending: false)
        .get();

    List<Inscription> inscriptions = [];
    List<Map<String, dynamic>> dataList = [];
    bool result = true;

    // Parse each document into an Inscription object and a map
    for (var doc in querySnapshot.docs) {
      Inscription inscription = Inscription.fromDocumentSnapshot(doc);
      inscriptions.add(inscription);

      if (cometionType == "adult_inscription") {
        if (inscription.noteTajwid![fullName] == null ||
            inscription.noteHousnSawtt![fullName] == null ||
            inscription.noteIltizamRiwaya![fullName] == null) {
          result = false; // If any of the constraints are not met
          break;
        }
      } else {
        if (inscription.noteTajwid![fullName] == null ||
            inscription.noteHousnSawtt![fullName] == null ||
            inscription.noteOu4oubetSawtt![fullName] == null ||
            inscription.noteWaqfAndIbtidaa![fullName] == null) {
          result = false; // If any of the constraints are not met
          break;
        }
      }

      dataList
          .add(inscription.toMap()); // Add to list if all constraints are met
    }

    return {
      "result": result,
      "dataList": result ? dataList : <Map<String, dynamic>>[],
    };
  }
}
