class ResultModel {
  String? fullName;
  double? generalMoyenne;
  int? idUser;

  ResultModel(
      {required this.fullName,
      required this.generalMoyenne,
      required this.idUser});

  // to Map
  Map<String, dynamic> toJson() => {
        'الإسم الثلاثي': fullName,
        'المعدل العالم': generalMoyenne,
        'رقم التسجيل': idUser,
      };

      // from Map
      ResultModel.fromMap(Map<String, dynamic> map) {
        fullName = map['الإسم الثلاثي'];
        generalMoyenne = map['المعدل العالم'];
        idUser = map['رقم التسجيل'];
      }
}
