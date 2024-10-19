import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';

class CusttomCard extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final String imageAsset;
  const CusttomCard({
    super.key,
    required this.text,
    required this.onTap,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: AppColors.whiteColor,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black12,
              )
            ]),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                imageAsset,
                width: double.infinity,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  color: Colors.white
                      .withOpacity(0.7), // Optional: Background for the text
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.blackColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
