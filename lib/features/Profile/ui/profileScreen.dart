import 'package:flutter/material.dart';
import 'package:daansure/constants.dart';
import 'package:daansure/features/Signup/widgets/appBranding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _panCardController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isPasswordVisible = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _panCardController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString('userId');

      if (_userId == null) {
        setState(() {
          _errorMessage = 'User not logged in';
          _isLoading = false;
        });
        return;
      }

      final supabase = Supabase.instance.client;
      final data =
          await supabase.from('users').select().eq('id', _userId!).single();

      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneNumberController.text = data['phone_number'] ?? '';
        _panCardController.text = data['pan_card_number'] ?? '';
        _passwordController.text = data['password'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user data';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;
      await supabase.from('users').update({
        'name': _nameController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'pan_card_number': _panCardController.text.trim(),
        'password': _passwordController.text,
      }).eq('id', _userId!);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Globals.customGreen,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile';
        _isSaving = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Globals.customGreen,
          ),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      // Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      
      if (mounted) {
        // Pop the loading dialog
        Navigator.pop(context);
        
        // Navigate to login screen and clear the navigation stack
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
    } catch (e) {
      // Pop the loading dialog if there's an error
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
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
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: Globals.customGreen),
                  )
                : _buildProfileContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Image.asset(
                'assets/DaanSure-Icon.png',
                height: Globals.screenHeight * 0.1,
              ),
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
                'Ensuring every donation is used right',
                style: TextStyle(
                  fontSize: Globals.screenHeight * 0.016,
                  color: Globals.customGreyDark,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.04),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Profile',
              style: TextStyle(
                fontSize: Globals.screenHeight * 0.025,
                fontWeight: FontWeight.bold,
                color: Globals.customBlack,
              ),
            ),
            _isEditing
                ? TextButton.icon(
                    onPressed: _isSaving ? null : _updateUserData,
                    icon: _isSaving
                        ? SizedBox(
                            height: Globals.screenHeight * 0.02,
                            width: Globals.screenHeight * 0.02,
                            child: CircularProgressIndicator(
                              color: Globals.customGreen,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.check, color: Globals.customGreen),
                    label: Text(
                      'Save',
                      style: TextStyle(
                        color: Globals.customGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: Icon(Icons.edit, color: Globals.customGreen),
                    label: Text(
                      'Edit',
                      style: TextStyle(
                        color: Globals.customGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
        SizedBox(height: Globals.screenHeight * 0.02),
        if (_errorMessage != null) ...[
          Container(
            padding: EdgeInsets.all(Globals.screenHeight * 0.01),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: Globals.screenWidth * 0.02),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Globals.screenHeight * 0.02),
        ],
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_outline,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'Phone Number',
                controller: _phoneNumberController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              _buildProfileField(
                label: 'PAN Card Number',
                controller: _panCardController,
                icon: Icons.credit_card_outlined,
                enabled: _isEditing,
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your PAN card number';
                  } else if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid PAN card number';
                  }
                  return null;
                },
              ),
              _buildPasswordField(),
              SizedBox(height: Globals.screenHeight * 0.02),
              _buildLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.w500,
            color: Globals.customBlack,
          ),
        ),
        SizedBox(height: Globals.screenHeight * 0.01),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            filled: true,
            fillColor: enabled
                ? Globals.customGreyLight
                : Globals.customGreyLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: Globals.screenHeight * 0.02,
              horizontal: Globals.screenWidth * 0.04,
            ),
          ),
          validator: validator,
        ),
        SizedBox(height: Globals.screenHeight * 0.025),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          enabled: _isEditing,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock_outline,
              color: Globals.customGreyDark,
              size: Globals.screenHeight * 0.025,
            ),
            suffixIcon: _isEditing
                ? IconButton(
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
                  )
                : null,
            filled: true,
            fillColor: _isEditing
                ? Globals.customGreyLight
                : Globals.customGreyLight.withOpacity(0.5),
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
        SizedBox(height: Globals.screenHeight * 0.025),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: Icon(
          Icons.logout,
          color: Colors.white,
        ),
        label: Text(
          'Logout',
          style: TextStyle(
            fontSize: Globals.screenHeight * 0.018,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(
            vertical: Globals.screenHeight * 0.02,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}