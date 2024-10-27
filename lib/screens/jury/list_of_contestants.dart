// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:provider/provider.dart';
// import 'package:quranic_competition/constants/colors.dart';
// import 'package:quranic_competition/models/inscription.dart';
// import 'package:quranic_competition/providers/auth_provider.dart';
// import 'package:quranic_competition/screens/jury/detail_contestant_screen.dart';
// import 'package:quranic_competition/services/auth_service.dart';
// import 'package:quranic_competition/services/inscription_service.dart';

// class ListOfContestants extends StatefulWidget {
//   final String competitionVersion;
//   final String competitionType;
//   const ListOfContestants(
//       {super.key,
//       required this.competitionType,
//       required this.competitionVersion});

//   @override
//   State<ListOfContestants> createState() => _ListOfContestantsState();
// }

// class _ListOfContestantsState extends State<ListOfContestants> {
//   List<Inscription> contestants = [];
//   @override
//   void initState() {
//     getContestants();
//     super.initState();
//   }

//   Future<void> getContestants() async {
//     List<Inscription> conts = await InscriptionService.fetchContestants(
//         widget.competitionVersion, widget.competitionType);
//     setState(() {
//       contestants = conts;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     AuthProvider authProvider =
//         Provider.of<AuthProvider>(context, listen: false);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         title: Text(widget.competitionType == "adult_inscription"
//             ? "لائحة المتسابقين الكبار"
//             : "لائحة المتسابقين الصغار"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(
//           8.0,
//         ),
//         child: SingleChildScrollView(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 top: 0,
//                 child: Image.asset(
//                   "assets/images/logos/logo.png",
//                   fit: BoxFit.cover,
//                   // height: 500,
//                 ),
//               ),
//               StreamBuilder<List<Inscription>>(
//                 stream: InscriptionService.streamContestants(
//                     widget.competitionVersion, widget.competitionType),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Text(
//                         "حدث خطأ أثناء جلب البيانات: ${snapshot.error}");
//                   }
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return SizedBox(
//                       height: MediaQuery.of(context).size.height,
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   }

//                   if (snapshot.data!.isEmpty) {
//                     return SizedBox(
//                       height: MediaQuery.of(context).size.height,
//                       child: const Center(
//                         child: Text("لا توجد بيانات"),
//                       ),
//                     );
//                   }

//                   List<Inscription> inscriptions = snapshot.data!;
//                   return SizedBox(
//                     height: MediaQuery.of(context).size.height,
//                     child: ListView.separated(
//                       scrollDirection: Axis.vertical,
//                       separatorBuilder: (context, index) => const SizedBox(
//                         height: 15.0,
//                       ),
//                       itemCount: inscriptions.length,
//                       itemBuilder: (context, index) {
//                         Inscription inscription = inscriptions[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => DetailContestantScreen(
//                                   inscription: inscription,
//                                   competitionType: widget.competitionType,
//                                   competitionVersion: widget.competitionVersion,
//                                 ),
//                               ),
//                             );
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 margin:
//                                     const EdgeInsets.symmetric(horizontal: 5.0),
//                                 padding: const EdgeInsets.all(8.0),
//                                 width: MediaQuery.of(context).size.width,
//                                 decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10.0),
//                                     color: AppColors.whiteColor,
//                                     boxShadow: [
//                                       BoxShadow(
//                                           color: AppColors.blackColor
//                                               .withOpacity(.3),
//                                           blurRadius: 1.0,
//                                           spreadRadius: 2.0,
//                                           blurStyle: BlurStyle.outer,
//                                           offset: const Offset(0, 1))
//                                     ]),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                         "المتسابق رقم : ${inscription.idInscription}"),
//                                     const SizedBox(
//                                       height: 10.0,
//                                     ),
//                                     Divider(
//                                       color:
//                                           AppColors.blackColor.withOpacity(.2),
//                                       height: 1,
//                                       indent: 50,
//                                       endIndent: 50,
//                                     ),
//                                     const SizedBox(
//                                       height: 10.0,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Center(
//                                             child: Column(
//                                               children: [
//                                                 const Text("التجويد"),
//                                                 const SizedBox(
//                                                   height: 5.0,
//                                                 ),
//                                                 Text(inscription.noteTajwid![
//                                                             authProvider
//                                                                 .currentUser!
//                                                                 .fullName] !=
//                                                         null
//                                                     ? inscription.noteTajwid![
//                                                             authProvider
//                                                                 .currentUser!
//                                                                 .fullName]
//                                                         .toString()
//                                                     : "0"),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: Center(
//                                             child: Column(
//                                               children: [
//                                                 const Text("حسن الصوت"),
//                                                 const SizedBox(
//                                                   height: 5.0,
//                                                 ),
//                                                 Text(inscription.noteHousnSawtt![
//                                                             authProvider
//                                                                 .currentUser!
//                                                                 .fullName] !=
//                                                         null
//                                                     ? inscription
//                                                         .noteHousnSawtt![
//                                                             authProvider
//                                                                 .currentUser!
//                                                                 .fullName]
//                                                         .toString()
//                                                     : "0"),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Visibility(
//                                           visible: widget.competitionType ==
//                                               "adult_inscription",
//                                           child: Expanded(
//                                             child: Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text(
//                                                       "الإلتزام بالرواية"),
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   inscription.noteIltizamRiwaya !=
//                                                           null
//                                                       ? Text(inscription
//                                                                       .noteIltizamRiwaya![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName] !=
//                                                               null
//                                                           ? inscription
//                                                               .noteIltizamRiwaya![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName]
//                                                               .toString()
//                                                           : "0")
//                                                       : Container(),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Visibility(
//                                           visible: widget.competitionType ==
//                                               "child_inscription",
//                                           child: Expanded(
//                                             child: Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text("عذوبة الصوت"),
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   inscription.noteOu4oubetSawtt !=
//                                                           null
//                                                       ? Text(inscription
//                                                                       .noteOu4oubetSawtt![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName] !=
//                                                               null
//                                                           ? inscription
//                                                               .noteOu4oubetSawtt![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName]
//                                                               .toString()
//                                                           : "0")
//                                                       : Container(),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                         Visibility(
//                                           visible: widget.competitionType ==
//                                               "child_inscription",
//                                           child: Expanded(
//                                             child: Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text("الوقف والإبتداء"),
//                                                   const SizedBox(
//                                                     height: 5.0,
//                                                   ),
//                                                   inscription.noteWaqfAndIbtidaa !=
//                                                           null
//                                                       ? Text(inscription
//                                                                       .noteWaqfAndIbtidaa![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName] !=
//                                                               null
//                                                           ? inscription
//                                                               .noteWaqfAndIbtidaa![
//                                                                   authProvider
//                                                                       .currentUser!
//                                                                       .fullName]
//                                                               .toString()
//                                                           : "0")
//                                                       : Container(),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Visibility(
//                                 visible: inscription.result![
//                                         authProvider.currentUser!.fullName] !=
//                                     null,
//                                 child: const Positioned(
//                                   top: 10,
//                                   right: 10,
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         "تم التصحيح",
//                                         style: TextStyle(
//                                           color: AppColors.greenColor,
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 5.0,
//                                       ),
//                                       Icon(
//                                         Iconsax.verify5,
//                                         color: AppColors.greenColor,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: contestants.isEmpty
//           ? null
//           : Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryColor,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () async {
//                   Map result = await AuthService.checkAllNotes(
//                       widget.competitionVersion,
//                       widget.competitionType,
//                       authProvider.currentUser!.fullName);
//                   bool isCheked = result["result"];
//                   List<Map<String, dynamic>> dataList = result["dataList"];
//                   if (isCheked && dataList.isNotEmpty) {
//                     // Send notes to the admin
//                     InscriptionService.exportDataAsXlsx(
//                         dataList,
//                         authProvider.currentUser!.fullName,
//                         widget.competitionVersion,
//                         widget.competitionType,
//                         context);
//                   } else {
//                     // Snackbar for failure
//                     final successSnackBar = SnackBar(
//                       content: const Text('لم يتم التصحيح لكل المتسابقين'),
//                       action: SnackBarAction(
//                         label: 'تراجع',
//                         onPressed: () {
//                           // Perform some action
//                         },
//                       ),
//                       backgroundColor: Colors.red,
//                     );
//                     ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
//                   }
//                 },
//                 child: const Text(
//                   "إرسال إلى الإدارة",
//                   style: TextStyle(
//                     color: AppColors.whiteColor,
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
