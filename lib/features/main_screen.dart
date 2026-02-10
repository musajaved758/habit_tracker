import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/widgets/custom_nav_bar.dart';
import 'package:iron_mind/core/utils/barrels/screens.dart';
import 'package:iron_mind/core/providers/app_providers.dart';
import 'package:iron_mind/features/challenge/presentation/screens/challenge_screen.dart';

class MainScreen extends HookConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final isSwapped = ref.watch(swapHomeAndChallengeProvider);
    final colors = Theme.of(context).appColors;

    final pages = isSwapped
        ? [
            const ChallengeScreen(),
            const HomeScreen(),
            const PhaseScreen(),
            const IntelScreen(),
            const SettingScreen(),
          ]
        : [
            const HomeScreen(),
            const ChallengeScreen(),
            const PhaseScreen(),
            const IntelScreen(),
            const SettingScreen(),
          ];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HabitScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: currentIndex,
        onTap: (index) {
          ref.read(navIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
