import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:contact_reminder/configs/colors.dart';
import 'package:contact_reminder/screens/contacts/contacts_screen.dart';
import 'package:contact_reminder/screens/track/track_screen.dart';
import 'package:flutter/material.dart';

import '../../widgets/contact_picker_dialog.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({Key? key}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedPageIndex = 0;
  final iconList = [
    Icons.call,
    Icons.people_alt_rounded,
  ];
  final _screens = [
    const ContactScreen(
      key: ValueKey("Contacts"),
    ),
    const TrackScreen(
      key: ValueKey("Settings"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedPageIndex = index;
          });
        },
        itemBuilder: (_, index) {
          return _screens[_selectedPageIndex];
        },
        itemCount: _screens.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showContactPickerDialog,
        child: const Icon(
          Icons.add,
          color: ColorPallet.whiteColor,
        ),
        backgroundColor: ColorPallet.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _selectedPageIndex,
        gapLocation: GapLocation.center,
        backgroundColor: ColorPallet.whiteColor,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        activeColor: ColorPallet.primaryColor,
        inactiveColor: ColorPallet.greyColor,
        onTap: (index) => setState(() => _selectedPageIndex = index),
        //other params
      ),
    );
  }

  showContactPickerDialog() async {
    showDialog(
      context: context,
      builder: (_) {
        return ContactPickerDialog();
      },
    );
  }
}
