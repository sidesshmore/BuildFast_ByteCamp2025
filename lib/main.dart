import 'package:daansure/constants.dart';
import 'package:daansure/features/BottomNav/ui/customNav.dart';
import 'package:daansure/features/Login/ui/loginScreen.dart';
import 'package:daansure/features/Signup/ui/signupScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final isLoggedIn = userId != null && userId.isNotEmpty;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(scaffoldBackgroundColor: Globals.customWhite),
    home: isLoggedIn ? const CustomNav() : const SignupScreen(),
    routes: {
      'signup': (context) => const SignupScreen(),
      'login': (context) => const LoginScreen(),
      'customNav': (context) => const CustomNav(),
    },
  ));
}
