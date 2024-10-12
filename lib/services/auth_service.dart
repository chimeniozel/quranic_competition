import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
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
      NoteResult noteResult,
      Inscription inscription,
      String competitionVersion,
      String competitionType,
      String competitionPhase) async {
    try {
      firebaseFirestore.collection("users");
      var cometitionTypeRef = firebaseFirestore
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection(competitionPhase)
          .doc(competitionPhase)
          .collection(competitionType)
          .doc(inscription.phoneNumber);

      noteResult.cheikhName = fullName;
      List<Users>? users =
          Provider.of<AuthProvider>(context, listen: false).users;
      int userIndex = 0;
      for (var i = 0; i < users!.length; i++) {
        if (users[i].fullName == fullName) {
          userIndex = i;
          break;
        }
      }
      DocumentSnapshot<Map<String, dynamic>> doc =
          await cometitionTypeRef.get();

      List<dynamic> myList = doc['tashihMachaikhs'];
      print("=================\n ${myList[userIndex]}");

      if (competitionType == "adult_inscription") {
        var result = noteResult.notes!.noteTajwid! +
            noteResult.notes!.noteHousnSawtt! +
            noteResult.notes!.noteIltizamRiwaya!;
        noteResult = NoteResult(
          cheikhName: fullName,
          notes: noteResult.notes!,
        );
        myList[userIndex] = noteResult.toMapAdult(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs": myList,
        });
      } else {
        var result = noteResult.notes!.noteTajwid! +
            noteResult.notes!.noteHousnSawtt! +
            noteResult.notes!.noteOu4oubetSawtt! +
            noteResult.notes!.noteWaqfAndIbtidaa!;
        noteResult = NoteResult(
          cheikhName: fullName,
          notes: noteResult.notes!,
        );
        myList[userIndex] = noteResult.toMapChild(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs": myList,
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

  static Future<Map<String, dynamic>> checkAllNotes(String version,
      String cometionType, String fullName, String competitionPhase) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(competitionPhase)
        .doc(competitionPhase)
        .collection(cometionType);

    QuerySnapshot querySnapshot = await inscriptionCollection
        .orderBy("رقم التسجيل", descending: false)
        .get();

    List<Inscription> inscriptions = [];
    List<Inscription> notedInscriptions = [];
    List<Map<String, dynamic>> dataList = [];

    // Parse each document into an Inscription object and a map
    for (var doc in querySnapshot.docs) {
      Inscription inscription = Inscription.fromDocumentSnapshot(doc);
      inscriptions.add(inscription);
      if (cometionType == "adult_inscription") {
        for (var note in inscription.tashihMachaikhs!) {
          NoteResult noteResult = NoteResult.fromMapAdult(note);
          if (noteResult.cheikhName == fullName &&
              noteResult.notes!.noteTajwid != 0 &&
              noteResult.notes!.noteHousnSawtt != 0 &&
              noteResult.notes!.noteIltizamRiwaya != 0) {
            dataList.add(noteResult.toMapAdult()!);
            notedInscriptions.add(inscription);
          }
        }
      } else {
        for (var note in inscription.tashihMachaikhs!) {
          NoteResult noteResult = NoteResult.fromMapChild(note);
          if (noteResult.cheikhName == fullName &&
              noteResult.notes!.noteTajwid != 0 &&
              noteResult.notes!.noteHousnSawtt != 0 &&
              noteResult.notes!.noteOu4oubetSawtt != 0 &&
              noteResult.notes!.noteWaqfAndIbtidaa != 0) {
            dataList.add(noteResult.toMapChild()!);
            notedInscriptions.add(inscription);
          }
        }
      }
    }

    if (inscriptions.length == dataList.length) {
      return {
        "isNoted": true,
        "notedInscriptions" : notedInscriptions,
        "dataList": dataList,
      };
    } else {
      return {
        "isNoted": false,
        "notedInscriptions" : <List<Inscription>>[],
        "dataList": <Map<String, dynamic>>[],
      };
    }

    // dataList
    //     .add(inscription.toMap()); // Add to list if all constraints are met
  }
}
