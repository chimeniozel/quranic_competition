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
    String competitionRound,
  ) async {
    try {
      firebaseFirestore.collection("users");
      var cometitionTypeRef = firebaseFirestore
          .collection("inscriptions")
          .doc(competitionVersion)
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

      List<dynamic> myList = doc['tashihMachaikhs'][competitionRound];
      print("=================\n ${myList[userIndex]}");

      if (competitionType == "adult_inscription") {
        noteResult = NoteResult(
            cheikhName: fullName,
            notes: noteResult.notes!,
            isCorrected: noteResult.isCorrected);
        myList[userIndex] = noteResult.toMapAdult(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs.$competitionRound": myList,
        });
      } else {
        noteResult = NoteResult(
            cheikhName: fullName,
            notes: noteResult.notes!,
            isCorrected: noteResult.isCorrected);
        myList[userIndex] = noteResult.toMapChild(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs.$competitionRound": myList,
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
      Navigator.pop(context);
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
      String cometionType, String fullName, String competitionRound) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
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
      if (competitionRound == "التصفيات الأولى") {
        if (cometionType == "adult_inscription") {
          for (var note in inscription.tashihMachaikhs!.firstRound!) {
            NoteResult noteResult = NoteResult.fromMapAdult(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapAdult()!);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var note in inscription.tashihMachaikhs!.firstRound!) {
            NoteResult noteResult = NoteResult.fromMapChild(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapChild()!);
              notedInscriptions.add(inscription);
            }
          }
        }
      } else {
        if (cometionType == "adult_inscription") {
          for (var note in inscription.tashihMachaikhs!.finalRound!) {
            NoteResult noteResult = NoteResult.fromMapAdult(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapAdult()!);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var note in inscription.tashihMachaikhs!.finalRound!) {
            NoteResult noteResult = NoteResult.fromMapChild(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapChild()!);
              notedInscriptions.add(inscription);
            }
          }
        }
      }
    }

    if (inscriptions.length == dataList.length) {
      return {
        "isNoted": true,
        "notedInscriptions": notedInscriptions,
        "dataList": dataList,
      };
    } else {
      return {
        "isNoted": false,
        "notedInscriptions": <Inscription>[],
        "dataList": <Map<String, dynamic>>[],
      };
    }
  }
}
