import 'package:daansure/constants.dart';
import 'package:flutter/material.dart';

class AppBranding extends StatelessWidget {
  const AppBranding({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/DaanSure-Icon.png',
              height: Globals.screenHeight * 0.1),
          SizedBox(height: Globals.screenHeight * 0.01),
          Text(
            'DaanSure',
            style: TextStyle(
              fontSize: Globals.screenHeight * 0.035,
              fontWeight: FontWeight.bold,
              color: Globals.customBlack,
            ),
          ),
          SizedBox(height: Globals.screenHeight * 0.005),
          Text(
            'Create your account',
            style: TextStyle(
              fontSize: Globals.screenHeight * 0.018,
              color: Globals.customGreyDark,
            ),
          ),
        ],
      ),
    );
  }
}
