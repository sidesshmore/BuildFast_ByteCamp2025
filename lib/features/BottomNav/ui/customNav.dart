import 'package:daansure/constants.dart';
import 'package:daansure/features/Home/ui/homeScreen.dart';
import 'package:daansure/features/Milestones/ui/milestoneScreen.dart';
import 'package:daansure/features/Profile/ui/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomNav extends StatefulWidget {
  const CustomNav({super.key});

  @override
  State<CustomNav> createState() => _CustomNavState();
}

class _CustomNavState extends State<CustomNav>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1; // Start with home screen selected
  late AnimationController _animationController;
  String? userId;

  final List<String> _screenNames = [
    'Bookmarks',
    'Home',
    'Profile',
  ];

  final List<Widget> _screens = [
    const MilestoneScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    LucideIcons.coins,
    LucideIcons.home,
    LucideIcons.user,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // Load user ID from SharedPreferences
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleScreenChange(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.mediumImpact();
      setState(() {
        _selectedIndex = index;
      });
      _animationController
        ..reset()
        ..forward();
    }
  }

  Widget _buildScreen(int index) {
    return _screens[index];
  }

  @override
  Widget build(BuildContext context) {
    Globals.initialize(context);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _icons.length,
          (index) => _buildScreen(index),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: Globals.screenHeight * 0.01),
        height: Globals.screenHeight * 0.09,
        decoration: BoxDecoration(
          color: Globals.customWhite,
          boxShadow: [
            BoxShadow(
              color: Globals.customBlack.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _icons.length,
            (index) => Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Globals.screenHeight * 0.02),
                ),
                onTap: () => _handleScreenChange(index),
                child: Container(
                  width: Globals.screenWidth * 0.17,
                  height: Globals.screenWidth * 0.17,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.all(Globals.screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: index == 1
                          ? Globals.customGreen
                          : _selectedIndex == index
                              ? Globals.customGreyLight
                              : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(Globals.screenHeight * 0.02),
                    ),
                    child: Icon(
                      _icons[index],
                      color: index == 1
                          ? Globals.customWhite
                          : _selectedIndex == index
                              ? Globals.customBlack
                              : Globals.customGreyDark,
                      size: Globals.screenHeight * 0.028,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
