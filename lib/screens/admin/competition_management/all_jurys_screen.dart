import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/providers/competion_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AllJurysScreen extends StatefulWidget {
  const AllJurysScreen({super.key});

  @override
  State<AllJurysScreen> createState() => _AllJurysScreenState();
}

class _AllJurysScreenState extends State<AllJurysScreen> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    CompetitionProvider competitionProvider =
        Provider.of<CompetitionProvider>(context, listen: false);
    AuthProviders authProviders =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('أعضاء لجنة التحكيم'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<Jury>>(
          future: CompetitionService.getAllJurys(),
          builder: (context, snapshot) {
            // Handle different states of Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No jury users available.'));
            }

            // If the data is available, build the ListView
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Jury jury = users[index];
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 3.0),
                  decoration: const BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0.0, 2.0),
                        blurRadius: 10.0,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            jury.fullName.toString(),
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(jury.phoneNumber),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () => _makePhoneCall(jury.phoneNumber),
                            child: const Text(
                              "اتصل",
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                          const SizedBox(width: 8.0), // Spacing between buttons
                          if (!jury.competitions!.contains(competitionProvider
                              .competition!.competitionVirsion))
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red, // Danger color for delete
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () {
                                // Show confirmation dialog before deletion
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تحذير: حذف المستخدم'),
                                    content: const Text(
                                      'هل أنت متأكد أنك تريد حذف هذا المستخدم؟ هذا الإجراء لا يمكن التراجع عنه.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            )),
                                        onPressed: () async {
                                          // Delete user from Firestore
                                          await CompetitionService.deleteUser(
                                            userID: jury.userID!,
                                            context: context,
                                          );
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor:
                                                  AppColors.greenColor,
                                              content: Text(
                                                  'تم حذف عضو لجنة التحكيم هذا بنجاح.'),
                                            ),
                                          );
                                          // Optionally, refresh the list
                                          setState(() {}); // Refresh the UI
                                        },
                                        child: const Text(
                                          'حذف',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                "حذف",
                                style: TextStyle(color: AppColors.whiteColor),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
