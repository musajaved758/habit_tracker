import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/core/utils/responsive.dart';
import 'package:operation_brotherhood/features/habit/presentation/providers/habit_provider.dart';

class HabitScreen extends HookConsumerWidget {
  const HabitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final noteController = useTextEditingController();
    final selectedCategory = useState('Study');
    final selectedFrequency = useState('DAILY');
    final targetValue = useState(1);
    final targetUnit = useState('TIMES');
    final isReminderOn = useState(true);
    final reminderTime = useState(const TimeOfDay(hour: 7, minute: 30));
    final difficulty = useState('MEDIUM');

    final categories = [
      {'name': 'Fitness', 'icon': Icons.fitness_center},
      {'name': 'Study', 'icon': Icons.menu_book},
      {'name': 'Discipline', 'icon': Icons.verified_user},
      {'name': 'Sleep', 'icon': Icons.nights_stay},
      {'name': 'Custom', 'icon': Icons.add},
    ];

    void handleCreateHabit() {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a habit name')),
        );
        return;
      }

      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.value.hour,
        reminderTime.value.minute,
      );

      ref
          .read(habitProvider.notifier)
          .addHabit(
            name: nameController.text,
            category: selectedCategory.value,
            frequency: selectedFrequency.value,
            targetValue: targetValue.value,
            targetUnit: targetUnit.value,
            reminderTime: isReminderOn.value ? reminderDateTime : null,
            difficulty: difficulty.value,
            motivationNote: noteController.text,
          );

      Navigator.pop(context);
    }

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      appBar: AppBar(
        backgroundColor: AppColors.habitBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Habit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: context.w(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.h(2)),

            // HABIT IDENTITY
            _sectionHeader('HABIT IDENTITY'),
            _customTextField(
              controller: nameController,
              hintText: 'e.g. Morning Meditation',
              label: 'Habit Name',
              maxLength: 30,
            ),

            SizedBox(height: context.h(3)),

            // CATEGORY
            _sectionHeader('CATEGORY'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories
                    .map(
                      (cat) => _categoryChip(
                        context,
                        cat['name'] as String,
                        cat['icon'] as IconData,
                        selectedCategory.value == cat['name'],
                        () => selectedCategory.value = cat['name'] as String,
                      ),
                    )
                    .toList(),
              ),
            ),

            SizedBox(height: context.h(3)),

            // FREQUENCY & GOAL
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('FREQUENCY'),
                      _frequencyToggle(
                        context,
                        selectedFrequency.value,
                        (val) => selectedFrequency.value = val,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('GOAL/TARGET'),
                      _goalInput(
                        context,
                        targetValue.value,
                        targetUnit.value,
                        (val) => targetValue.value = val,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: context.h(3)),

            // MISSION ALERT
            _sectionHeader('MISSION ALERT'),
            _reminderCard(
              context,
              isReminderOn.value,
              reminderTime.value,
              (val) => isReminderOn.value = val,
              (val) => reminderTime.value = val,
            ),

            SizedBox(height: context.h(3)),

            // DIFFICULTY LEVEL
            _sectionHeader('DIFFICULTY LEVEL'),
            _difficultySelector(
              context,
              difficulty.value,
              (val) => difficulty.value = val,
            ),

            SizedBox(height: context.h(3)),

            // MOTIVATION NOTE
            _sectionHeader('MOTIVATION NOTE'),
            _motivationField(noteController),

            SizedBox(height: context.h(4)),

            // CREATE HABIT BUTTON
            _createHabitButton(context, handleCreateHabit),

            SizedBox(height: context.h(5)),
          ],
        ),
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

  Widget _customTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required int maxLength,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                '0/$maxLength',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ],
          ),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 18),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(
    BuildContext context,
    String name,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.habitCategoryBlue
              : AppColors.habitSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.habitBorder.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.habitPrimary.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.habitIconGrey,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.habitIconGrey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frequencyToggle(
    BuildContext context,
    String selected,
    Function(String) onSelect,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: ['DAILY', 'WEEKLY'].map((freq) {
          bool isSel = selected == freq;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(freq),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.habitPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  freq,
                  style: TextStyle(
                    color: isSel ? Colors.white : AppColors.habitIconGrey,
                    fontSize: 12,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _goalInput(
    BuildContext context,
    int value,
    String unit,
    Function(int) onValueChange,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 1,
            color: Colors.white12,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: AppColors.habitIconGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.habitIconGrey,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _reminderCard(
    BuildContext context,
    bool isOn,
    TimeOfDay time,
    Function(bool) onToggle,
    Function(TimeOfDay) onTimeChange,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.habitPrimary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.habitPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Reminder',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'NOTIFICATION SYSTEM ACTIVE',
                      style: TextStyle(
                        color: AppColors.habitIconGrey,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: isOn,
                  onChanged: onToggle,
                  activeColor: Colors.white,
                  activeTrackColor: AppColors.habitPrimary,
                  inactiveThumbColor: AppColors.habitIconGrey,
                  inactiveTrackColor: Colors.white12,
                ),
              ],
            ),
          ),
          if (isOn) ...[
            Container(height: 1, color: Colors.white.withOpacity(0.05)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _timeColumn('06', '07', '08', true),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      ':',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _timeColumn('25', '30', '35', false),
                  const SizedBox(width: 15),
                  Column(
                    children: [
                      const Text(
                        'AM',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                      Text(
                        'AM',
                        style: TextStyle(
                          color: AppColors.habitPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'PM',
                        style: TextStyle(color: Colors.white24, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeColumn(String prev, String current, String next, bool isPrimary) {
    return Column(
      children: [
        Text(prev, style: const TextStyle(color: Colors.white10, fontSize: 18)),
        Text(
          current,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(next, style: const TextStyle(color: Colors.white10, fontSize: 18)),
      ],
    );
  }

  Widget _difficultySelector(
    BuildContext context,
    String selected,
    Function(String) onSelect,
  ) {
    return Row(
      children: [
        Expanded(
          child: _difficultyChip(
            'EASY',
            AppColors.easyColor,
            selected == 'EASY',
            () => onSelect('EASY'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _difficultyChip(
            'MEDIUM',
            AppColors.mediumColor,
            selected == 'MEDIUM',
            () => onSelect('MEDIUM'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _difficultyChip(
            'HARD',
            AppColors.hardColor,
            selected == 'HARD',
            () => onSelect('HARD'),
          ),
        ),
      ],
    );
  }

  Widget _difficultyChip(
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.habitSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : AppColors.habitBorder.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.habitIconGrey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.habitSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.habitBorder.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          hintText: "Define your 'Why'... Success is the only option.",
          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _createHabitButton(BuildContext context, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.habitPrimary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.habitPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.rocket_launch, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text(
              'CREATE HABIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
