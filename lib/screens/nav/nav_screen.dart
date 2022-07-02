import 'dart:ui';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:contact_reminder/configs/colors.dart';
import 'package:contact_reminder/screens/contacts/contacts_screen.dart';
import 'package:contact_reminder/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedPageIndex = 0;
  final iconList = [
    Icons.call,
    Icons.settings,
  ];
  final _screens = [
    const ContactScreen(),
    const SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          (_selectedPageIndex == 0 ? "Contact History" : "Settings")
              .toUpperCase(),
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: PageView.builder(
        itemBuilder: (_, index) {
          return _screens[_selectedPageIndex];
        },
        itemCount: _screens.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: ColorPallet.secondaryColor,
        ),
        backgroundColor: ColorPallet.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _selectedPageIndex,
        gapLocation: GapLocation.center,
        backgroundColor: ColorPallet.secondaryColor,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        activeColor: ColorPallet.whiteColor,
        inactiveColor: ColorPallet.secondaryWhiteColor.withOpacity(0.7),
        onTap: (index) => setState(() => _selectedPageIndex = index),
        //other params
      ),
    );
  }
}
