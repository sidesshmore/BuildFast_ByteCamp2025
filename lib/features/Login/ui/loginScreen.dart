import 'package:daansure/constants.dart';
import 'package:daansure/features/Signup/widgets/appBranding.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final supabase = Supabase.instance.client;

        // First try to sign in through Supabase Auth
        final response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null) {
          // Store user ID in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', response.user!.id);

          if (mounted) {
            Navigator.pushReplacementNamed(context, 'customNav');
          }
        }
      } on AuthException catch (e) {
        // Handle the specific "Email not confirmed" error
        if (e.message.contains('Email not confirmed')) {
          // Check if the user exists in our custom users table
          try {
            final supabase = Supabase.instance.client;
            final data = await supabase
                .from('users')
                .select()
                .eq('email', _emailController.text.trim())
                .eq('password', _passwordController.text)
                .single();

            if (data != null) {
              // User exists in our database, but email not confirmed in Auth
              // For demo purposes, we'll allow login anyway
              final prefs = await SharedPreferences.getInstance();
              // Use the ID from our users table
              await prefs.setString('userId', data['id'].toString());

              if (mounted) {
                Navigator.pushReplacementNamed(context, 'customNav');
              }
              return;
            }
          } catch (dbError) {
            // If not found in custom table or other error, show original error
            setState(() {
              _errorMessage = 'Invalid email or password';
            });
          }
        } else {
          setState(() {
            _errorMessage = e.message;
          });
        }
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

                  // App logo and branding
                  const AppBranding(),

                  SizedBox(height: Globals.screenHeight * 0.04),

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
                      hintText: 'Enter your password',
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
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigate to forgot password screen or show a dialog
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Globals.customGreen,
                          fontSize: Globals.screenHeight * 0.015,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    SizedBox(height: Globals.screenHeight * 0.01),
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
                    SizedBox(height: Globals.screenHeight * 0.02),
                  ],

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: Globals.screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Globals.customGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: Globals.screenHeight * 0.015),
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
                              'Log In',
                              style: TextStyle(
                                fontSize: Globals.screenHeight * 0.018,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: Globals.screenHeight * 0.025),

                  // Sign up link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Globals.customGreyDark,
                            fontSize: Globals.screenHeight * 0.016,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, 'signup');
                          },
                          child: Text(
                            'Sign Up',
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

                  // Resend confirmation email option
                  SizedBox(height: Globals.screenHeight * 0.025),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        if (_emailController.text.isNotEmpty) {
                          try {
                            final supabase = Supabase.instance.client;
                            await supabase.auth.resend(
                              type: OtpType.signup,
                              email: _emailController.text.trim(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Confirmation email resent!'),
                                  backgroundColor: Globals.customGreen,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Failed to resend confirmation email'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          setState(() {
                            _errorMessage = 'Please enter your email first';
                          });
                        }
                      },
                      child: Text(
                        'Resend Confirmation Email',
                        style: TextStyle(
                          color: Globals.customGreen,
                          fontSize: Globals.screenHeight * 0.015,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
