import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/providers/auth_provider.dart';

class ReviewCompetion extends StatefulWidget {
  final String itemUrl;
  final String competitionId;
  const ReviewCompetion({
    super.key,
    required this.itemUrl,
    required this.competitionId,
  });

  @override
  State<ReviewCompetion> createState() => _ReviewCompetionState();
}

class _ReviewCompetionState extends State<ReviewCompetion> {
  @override
  Widget build(BuildContext context) {
    String itemUrl = widget.itemUrl;
    return Consumer<AuthProviders>(builder: (context, authProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text('معاينة الصورة',
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(
            8.0,
          ),
          width: double.infinity,
          child: Image.network(
                  itemUrl,
                  fit: BoxFit.contain,
                ),
        ),
      );
    });
  }
}
