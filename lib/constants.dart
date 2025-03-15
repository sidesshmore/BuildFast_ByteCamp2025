import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Globals {
  static double screenHeight = 0;
  static double screenWidth = 0;

  static Color customGreen = Color(0xff118B50);
  static Color customWhite = Color(0xffFAFAFA);
  static Color customBlack = Color(0xff0A0A0A);
  static Color customGreyLight = Color(0xffF4F3FD);
  static Color customGreyDark = Color(0xff858597);

  static void initialize(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
  }
}
