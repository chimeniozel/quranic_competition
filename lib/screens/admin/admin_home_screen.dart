// import 'package:flutter/material.dart';
// import 'package:quranic_competition/constants/colors.dart';
// import 'package:quranic_competition/screens/admin/competition_management/competition_management.dart';
// import 'package:quranic_competition/widgets/row_button_widget.dart';

// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({super.key});

//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }

// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('لوحة تحكم المشرف'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(
//                     child: CusttomButton(
//                       text: "إدارة المسابقة",
//                       backgroundColor: AppColors.primaryColor,
//                       minimumSize: const Size(
//                         double.infinity,
//                         70.0,
//                       ),
//                       style: const TextStyle(
//                         color: AppColors.whiteColor,
//                       ),
//                       onPressed: () {
//                         // Navigate to the inscription screen
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const CompetitionManagement(),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 16.0),
//                   Expanded(
//                     child: CusttomButton(
//                       text: "أرشيف المسابقة",
//                       backgroundColor: AppColors.primaryColor,
//                       minimumSize: const Size(
//                         double.infinity,
//                         70.0,
//                       ),
//                       style: const TextStyle(
//                         color: AppColors.whiteColor,
//                       ),
//                       onPressed: () {
//                         // Navigate to the competition schedule screen
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => const RegisterScreen(),
//                         //   ),
//                         // );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
