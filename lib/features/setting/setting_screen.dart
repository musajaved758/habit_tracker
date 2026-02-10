import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/core/providers/theme_provider.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionHeader('APPEARANCE'),
          const SizedBox(height: 16),
          _buildThemeSelector(context, ref, currentTheme),
          const SizedBox(height: 40),
          _sectionHeader('ABOUT'),
          const SizedBox(height: 16),
          _buildInfoCard('Version', '1.0.0', Icons.info_outline),
          const SizedBox(height: 12),
          _buildInfoCard('Developer', 'Operation Brotherhood', Icons.code),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.habitIconGrey,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context,
            ref,
            'Light Mode',
            Icons.light_mode,
            ThemeMode.light,
            currentTheme == ThemeMode.light,
          ),
          Divider(
            color: AppColors.habitBorder.withOpacity(0.3),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildThemeOption(
            context,
            ref,
            'Dark Mode',
            Icons.dark_mode,
            ThemeMode.dark,
            currentTheme == ThemeMode.dark,
          ),
          Divider(
            color: AppColors.habitBorder.withOpacity(0.3),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildThemeOption(
            context,
            ref,
            'System Default',
            Icons.settings_suggest,
            ThemeMode.system,
            currentTheme == ThemeMode.system,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        ref.read(themeModeProvider.notifier).state = mode;
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.habitPrimary.withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.habitPrimary : Colors.white70,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.habitPrimary,
                size: 24,
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
