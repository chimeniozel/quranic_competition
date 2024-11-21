import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/constants/utils.dart';
import 'package:quranic_competition/models/quranic_benefit.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/admin/benefits/add_quranic_benefit_screen.dart';

class QuranicBenefitScreen extends StatefulWidget {
  const QuranicBenefitScreen({super.key});

  @override
  State<QuranicBenefitScreen> createState() => _QuranicBenefitScreenState();
}

class _QuranicBenefitScreenState extends State<QuranicBenefitScreen> {
  @override
  Widget build(BuildContext context) {
    AuthProviders authProvider =
        Provider.of<AuthProviders>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('الفوائد القرآنية'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<List<QuranicBenefit>>(
            stream: QuranicBenefit
                .getAllQuranicBenefits(), // Ensure this is a Stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('لا تتم إضافة فوائد قرآنية.'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    QuranicBenefit benefit = snapshot.data![index];
                    return Container(
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
                      margin: const EdgeInsets.symmetric(
                        vertical: 3.0,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.grayLigthColor,
                            child: Image.asset("assets/images/logos/logo.png"),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  benefit.description.toString(),
                                  style: const TextStyle(fontSize: 14.0),
                                ),
                                // const SizedBox(height: 8.0),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (authProvider.currentAdmin == null)
                                      const Expanded(
                                        child: Text(
                                          'من طرف: مسابقة أهل القرآن الواتسابية',
                                          style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        "${Utils.arDateFormat(benefit.createdAt!)} - ${benefit.createdAt!.minute} : ${benefit.createdAt!.hour}",
                                        style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black),
                                      ),
                                    ),
                                    if (authProvider.currentAdmin != null)
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              // Navigate to the Add benefits
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddQuranicBenefitScreen(
                                                    quranicBenefit: benefit,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Iconsax.edit,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              // Show confirmation dialog to delete the competition
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                    'تحذير: حذف فائدة',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .red), // Change title color to red
                                                  ),
                                                  content: const Text(
                                                    'هل أنت متأكد أنك تريد حذف هذه الفائدة؟ هذا الإجراء لا يمكن التراجع عنه.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child:
                                                          const Text('إلغاء'),
                                                    ),
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .red, // Set background color to red
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              )),
                                                      onPressed: () async {
                                                        // remove benefits
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "quranic_benefits")
                                                            .doc(benefit
                                                                .idBenefit)
                                                            .delete()
                                                            .then((_) {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'تم حذف الفائدة بنجاح'),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .greenColor,
                                                            ),
                                                          );
                                                        }).catchError((error) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'خطأ في الحذف: $error'),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .grayColor,
                                                            ),
                                                          );
                                                        });
                                                      },
                                                      child: const Text(
                                                        'حذف',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white), // Set text color to white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Iconsax.note_remove,
                                              color: AppColors.pinkColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          )),
      floatingActionButton: authProvider.user != null
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddQuranicBenefitScreen(),
                  ),
                );
              },
              child: const Icon(Iconsax.add),
            )
          : null,
    );
  }
}
