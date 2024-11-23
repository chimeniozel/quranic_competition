import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AllAdminsScreen extends StatefulWidget {
  const AllAdminsScreen({super.key});

  @override
  State<AllAdminsScreen> createState() => _AllAdminsScreenState();
}

class _AllAdminsScreenState extends State<AllAdminsScreen> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (await canLaunchUrl(Uri.parse('tel:$phoneNumber'))) {
      await launchUrl(Uri.parse('tel:$phoneNumber'));
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProviders authProviders =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('أعضاء الإدارة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Admin>>(
          stream: CompetitionService.getAllAdminsStream(
              authProviders.currentAdmin!.userID!),
          builder: (context, snapshot) {
            // Handle different states of Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No admin users available.'));
            }

            // If the data is available, build the ListView
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Admin admin = users[index];
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              admin.fullName.toString(),
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            admin.isVerified!
                                ? const Row(
                                    children: [
                                      Text(
                                        "تم التحقق",
                                        style: TextStyle(
                                          color: AppColors.greenColor,
                                        ),
                                      ),
                                      SizedBox(width: 5.0),
                                      Icon(Iconsax.verify5,
                                          color: AppColors.greenColor),
                                    ],
                                  )
                                : const Row(
                                    children: [
                                      Text(
                                        "لم يتم التحقق",
                                        style: TextStyle(
                                          color: AppColors.pinkColor,
                                        ),
                                      ),
                                      SizedBox(width: 5.0),
                                      Icon(Iconsax.verify,
                                          color: AppColors.pinkColor),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          if (!admin.isVerified!)
                            TextButton(
                              onPressed: () {
                                CompetitionService.verifyUser(
                                    userID: admin.userID!);
                              },
                              child: const Text(
                                "توتيق",
                                style: TextStyle(color: AppColors.greenColor),
                              ),
                            ),
                          const SizedBox(width: 8.0),
                          TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            onPressed: () => _makePhoneCall(admin.phoneNumber),
                            child: const Text(
                              "اتصل",
                              style: TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                          const SizedBox(width: 8.0), // Spacing between buttons

                          TextButton(
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
                                  title: const Text('تحذير: حذف عضو'),
                                  content: const Text(
                                    'هل أنت متأكد أنك تريد حذف هذا العضو؟ هذا الإجراء لا يمكن التراجع عنه.',
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
                                          userID: admin.userID!,
                                        );
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor:
                                                AppColors.greenColor,
                                            content:
                                                Text('تم حذف هذا العضو بنجاح.'),
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
