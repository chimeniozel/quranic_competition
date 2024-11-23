import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';

class QuranicBenefit {
  String? _idBenefit;
  String? _description;
  String? _addByName;
  DateTime? _createdAt;
  QuranicBenefit({String? idBenefit, String? description, String? addByName})
      : _idBenefit = idBenefit,
        _description = description,
        _createdAt = DateTime.now(),
        _addByName = addByName;

  // Getters
  String? get idBenefit => _idBenefit;
  String? get description => _description;
  String? get addByName => _addByName;
  DateTime? get createdAt => _createdAt;

  // Setters
  void setidBenefit(String? value) {
    _idBenefit = value;
  }

  void setDescription(String value) {
    _description = value;
  }

  void setAddByName(String value) {
    _addByName = value;
  }

  void setCreatedAt(DateTime? value) {
    _createdAt = value;
  }

  // to Map
  Map<String, dynamic> toMap() {
    return {
      'idBenefit': idBenefit,
      'description': description,
      'addByName': addByName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // from Map
  QuranicBenefit.fromMap(Map<String, dynamic> map) {
    _idBenefit = map['idBenefit'];
    _description = map['description'];
    _addByName = map['addByName'];
    _createdAt = DateTime.parse(map['createdAt']);
  }

  // add to firebase db
  static Future<void> addQuranicBenefit(
      QuranicBenefit quranicBenefit, BuildContext context) async {
    try {
      // Add the Quranic benefit to the Firestore collection
      var doc = await FirebaseFirestore.instance
          .collection("quranic_benefits")
          .add(quranicBenefit.toMap());

      // Update the document with its ID
      await FirebaseFirestore.instance
          .collection("quranic_benefits")
          .doc(doc.id)
          .update({
        'idBenefit': doc.id,
      });

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت إضافة الفائدة بنجاح'),
          backgroundColor: AppColors.greenColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في إضافة الفائدة'),
          backgroundColor: AppColors.pinkColor,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error adding Quranic benefit: $e");
    }
  }

  // update the benefit
  static Future<void> updateQuranicBenefit(
      QuranicBenefit quranicBenefit, BuildContext context) async {
    try {
      // Update the document with its ID
      await FirebaseFirestore.instance
          .collection("quranic_benefits")
          .doc(quranicBenefit.idBenefit)
          .update(quranicBenefit.toMap());

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت تعديل الفائدة بنجاح'),
          backgroundColor: AppColors.greenColor,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في تعديل الفائدة'),
          backgroundColor: AppColors.pinkColor,
          duration: Duration(seconds: 2),
        ),
      );
      print("Error adding Quranic benefit: $e");
    }
  }

  static Stream<List<QuranicBenefit>> getAllQuranicBenefits() {
    return FirebaseFirestore.instance
        .collection("quranic_benefits")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return QuranicBenefit.fromMap(doc.data());
      }).toList();
    });
  }
}
