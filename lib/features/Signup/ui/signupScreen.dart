import 'package:daansure/constants.dart';
import 'package:daansure/features/Signup/widgets/appBranding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _panCardController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isFirstScreen = true;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Globals.initialize(context);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _panCardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToSecondScreen() {
    // Validate first screen inputs
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isFirstScreen = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final supabase = Supabase.instance.client;
        final response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          // Insert user data in the users table
          await supabase.from('users').insert({
            'name': _nameController.text.trim(),
            'phone_number': _phoneNumberController.text.trim(),
            'pan_card_number': _panCardController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          });

          // Store user ID in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', response.user!.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created successfully!'),
                backgroundColor: Globals.customGreen,
              ),
            );
            Navigator.pushReplacementNamed(context, 'customNav');
          }
        }
      } on AuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'An unexpected error occurred';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildFirstScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name field
        Text(
          'Full Name',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
            prefixIcon: Icon(
              Icons.person_outline,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            filled: true,
            fillColor: Globals.customGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),

        SizedBox(height: Globals.screenHeight * 0.025),

        // Phone Number field
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            hintStyle: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            filled: true,
            fillColor: Globals.customGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Please enter a valid 10-digit phone number';
            }
            return null;
          },
        ),

        SizedBox(height: Globals.screenHeight * 0.025),

        // PAN Card field
        Text(
          'PAN Card Number',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: _panCardController,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'Enter your PAN card number',
            hintStyle: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
            prefixIcon: Icon(
              Icons.credit_card_outlined,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            filled: true,
            fillColor: Globals.customGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your PAN card number';
            } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value)) {
              return 'Please enter a valid PAN card number';
            }
            return null;
          },
        ),

        SizedBox(height: Globals.screenHeight * 0.04),

        // Next button
        SizedBox(
          width: double.infinity,
          height: Globals.screenHeight * 0.06,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _goToSecondScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Globals.customGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  EdgeInsets.symmetric(vertical: Globals.screenHeight * 0.015),
            ),
            child: _isLoading
                ? SizedBox(
                    height: Globals.screenHeight * 0.02,
                    width: Globals.screenHeight * 0.02,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Next',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        // Login link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Globals.customGreyDark,
                  fontSize: Globals.screenHeight * 0.016,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'login');
                },
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Globals.customGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: Globals.screenHeight * 0.016,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        GestureDetector(
          onTap: () {
            setState(() {
              _isFirstScreen = true;
            });
          },
          child: Row(
            children: [
              Icon(
                Icons.arrow_back,
                color: Globals.customBlack,
                size: Globals.screenHeight * 0.025,
              ),
              SizedBox(width: Globals.screenWidth * 0.02),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.016,
                  color: Globals.customBlack,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: Globals.screenHeight * 0.02),

        // Email field
        Text(
          'Email',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            filled: true,
            fillColor: Globals.customGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                .hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),

        SizedBox(height: Globals.screenHeight * 0.025),

        // Password field
        Text(
          'Password',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Create a password',
            hintStyle: TextStyle(
              color: Globals.customGreyDark,
              fontSize: Globals.screenHeight * 0.016,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Globals.customGreyDark,
                size: Globals.screenHeight * 0.025,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            filled: true,
            fillColor: Globals.customGreyLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
        ),

        if (_errorMessage != null) ...[
          SizedBox(height: Globals.screenHeight * 0.02),
          Container(
            padding: EdgeInsets.all(Globals.screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: Globals.screenHeight * 0.02,
                ),
                SizedBox(width: Globals.screenWidth * 0.02),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: Globals.screenHeight * 0.014,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        SizedBox(height: Globals.screenHeight * 0.04),

        // Sign up button
        SizedBox(
          width: double.infinity,
          height: Globals.screenHeight * 0.06,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _signUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Globals.customGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding:
                  EdgeInsets.symmetric(vertical: Globals.screenHeight * 0.015),
            ),
            child: _isLoading
                ? SizedBox(
                    height: Globals.screenHeight * 0.02,
                    width: Globals.screenHeight * 0.02,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: Globals.screenHeight * 0.018,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        SizedBox(height: Globals.screenHeight * 0.025),

        // Login link
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(
                  color: Globals.customGreyDark,
                  fontSize: Globals.screenHeight * 0.016,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'login');
                },
                child: Text(
                  'Log In',
                  style: TextStyle(
                    color: Globals.customGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: Globals.screenHeight * 0.016,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Globals.screenWidth * 0.08,
              vertical: Globals.screenHeight * 0.03,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Globals.screenHeight * 0.03),
                  // Logo and App name
                  AppBranding(),

                  SizedBox(height: Globals.screenHeight * 0.04),

                  // Display either first or second screen based on state
                  _isFirstScreen ? _buildFirstScreen() : _buildSecondScreen(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
