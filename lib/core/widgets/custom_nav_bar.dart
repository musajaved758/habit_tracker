import 'package:flutter/material.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/core/utils/responsive.dart';

class CustomNavBar extends StatelessWidget {
  final Function(int) onTap;
  final selectedIndex;
  const CustomNavBar({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.hp(8) ,
      padding: context.screenPadding,
      decoration: BoxDecoration(
        border: BoxBorder.fromLTRB(top: BorderSide(color: AppColors.border)),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            navItem(() => onTap(0), Icons.home, selectedIndex == 0),
            navItem(() => onTap(1), Icons.rocket_launch, selectedIndex == 1),
            SizedBox(width: 28,),
            navItem(
                  () => onTap(2),
              Icons.electric_bolt_outlined,
              selectedIndex == 2,
            ),
            navItem(() => onTap(3), Icons.settings, selectedIndex == 3),
          ],
        ),
      ),
    );
  }
}

Widget navItem(VoidCallback onTap, IconData icon, bool isSelected) =>
    IconButton(
      onPressed: onTap,
      icon: Icon(icon,size: 28,),
      color: isSelected ? AppColors.iconSelected : AppColors.iconPrimary,
    );
