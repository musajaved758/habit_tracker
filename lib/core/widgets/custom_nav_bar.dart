import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/utils/responsive.dart';
import 'package:iron_mind/core/providers/app_providers.dart';

class CustomNavBar extends HookConsumerWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSwapped = ref.watch(swapHomeAndChallengeProvider);
    final colors = Theme.of(context).appColors;

    return Container(
      height: context.hp(10),
      decoration: BoxDecoration(
        color: colors.navBar,
        border: Border(top: BorderSide(color: colors.navBarBorder)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (isSwapped) ...[
              _navItem(0, Icons.military_tech_rounded, 'CHALLENGES', colors),
              _navItem(1, Icons.grid_view_rounded, 'HABIT', colors),
            ] else ...[
              _navItem(0, Icons.grid_view_rounded, 'HABIT', colors),
              _navItem(1, Icons.military_tech_rounded, 'CHALLENGES', colors),
            ],
            _navItem(2, Icons.calendar_today_rounded, 'PHASES', colors),
            _navItem(3, Icons.show_chart_rounded, 'PROGRESS', colors),
            _navItem(4, Icons.settings_rounded, 'SETTINGS', colors),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData icon,
    String label,
    AppColorScheme colors,
  ) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? colors.iconActive : colors.iconInactive;

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
