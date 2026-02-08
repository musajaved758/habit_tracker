import 'package:flutter/material.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/core/utils/responsive.dart';
import 'package:operation_brotherhood/core/widgets/custom_nav_bar.dart';
import 'package:operation_brotherhood/core/utils/barrels/screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final pages = const [
    HomeScreen(),
    PhaseScreen(),
    ProgressScreen(),
    SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: context.hp(.5)),
        child: FloatingActionButton(
          backgroundColor: AppColors.glowingGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(200),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HabitScreen()),
            );
            // showDialog(
            //   context: context,
            //   builder: (context) => const AddHabitDialog(),
            // );
          },
          child: const Icon(Icons.add),
        ),
      ),
      extendBody: true,

      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
