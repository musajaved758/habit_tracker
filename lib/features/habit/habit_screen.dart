import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/core/utils/responsive.dart';
import 'package:iron_mind/features/habit/presentation/providers/habit_provider.dart';
import 'package:iron_mind/features/challenge/presentation/providers/challenge_provider.dart';
import 'package:iron_mind/features/challenge/data/models/challenge_model.dart';
import 'package:uuid/uuid.dart';

import 'package:iron_mind/features/habit/data/models/habit_model.dart';

class HabitScreen extends HookConsumerWidget {
  final ChallengeModel? challengeToEdit;
  final HabitModel? habitToEdit;

  const HabitScreen({super.key, this.challengeToEdit, this.habitToEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final noteController = useTextEditingController();
    final selectedCategory = useState('Fitness');
    final selectedIcon = useState(0xe24a); // Icons.fitness_center
    final selectedFrequency = useState('DAILY');
    final targetValue = useState(1);
    final targetUnit = useState('TIMES');
    final endDate = useState(DateTime.now().add(const Duration(days: 30)));
    final priority = useState('MEDIUM');
    final colors = Theme.of(context).appColors;

    final categories = useState([
      {'name': 'Fitness', 'icon': Icons.fitness_center},
      {'name': 'Study', 'icon': Icons.menu_book},
      {'name': 'Discipline', 'icon': Icons.verified_user},
      {'name': 'Sleep', 'icon': Icons.nights_stay},
    ]);

    void _showCustomCategoryDialog() {
      showDialog(
        context: context,
        builder: (context) => _CustomCategoryDialog(
          onAdded: (name, icon) {
            categories.value = [
              ...categories.value,
              {'name': name, 'icon': icon},
            ];
            selectedCategory.value = name;
            selectedIcon.value = icon.codePoint;
          },
        ),
      );
    }

    final chNameController = useTextEditingController();
    final chDurationController = useTextEditingController(text: '30');
    final threatLevel = useState('HARD');
    final chConsequenceType = useState('PHYSICAL');
    final specificConsequence = useState('COLD SHOWER');
    final roadmap = useState<List<ChallengeMilestone>>([]);

    final creationMode = useState('HABIT');

    useEffect(() {
      if (challengeToEdit != null) {
        creationMode.value = 'CHALLENGE';
        chNameController.text = challengeToEdit!.name;
        chDurationController.text = challengeToEdit!.duration.toString();
        threatLevel.value = challengeToEdit!.threatLevel;
        chConsequenceType.value = challengeToEdit!.consequenceType;
        specificConsequence.value = challengeToEdit!.specificConsequence;
        roadmap.value = challengeToEdit!.roadmap;
      } else if (habitToEdit != null) {
        creationMode.value = 'HABIT';
        nameController.text = habitToEdit!.name;
        selectedCategory.value = habitToEdit!.category;
        selectedIcon.value = habitToEdit!.categoryIcon;
        selectedFrequency.value = habitToEdit!.frequency;
        targetValue.value = habitToEdit!.targetValue;
        targetUnit.value = habitToEdit!.targetUnit;
        endDate.value = habitToEdit!.endDate;
        priority.value = habitToEdit!.priority;
        noteController.text = habitToEdit!.motivationNote;
      }
      return null;
    }, []);

    void handleCreateHabit() {
      if (nameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a habit name')),
        );
        return;
      }

      if (habitToEdit != null) {
        ref
            .read(habitProvider.notifier)
            .updateHabit(
              id: habitToEdit!.id,
              name: nameController.text,
              category: selectedCategory.value,
              categoryIcon: selectedIcon.value,
              frequency: selectedFrequency.value,
              targetValue: targetValue.value,
              targetUnit: targetUnit.value,
              reminderTime: null,
              priority: priority.value,
              motivationNote: noteController.text,
              endDate: endDate.value,
              createdAt: habitToEdit!.createdAt,
              completedDates: habitToEdit!.completedDates,
            );
      } else {
        ref
            .read(habitProvider.notifier)
            .addHabit(
              name: nameController.text,
              category: selectedCategory.value,
              categoryIcon: selectedIcon.value,
              frequency: selectedFrequency.value,
              targetValue: targetValue.value,
              targetUnit: targetUnit.value,
              reminderTime: null,
              priority: priority.value,
              motivationNote: noteController.text,
              endDate: endDate.value,
            );
      }

      Navigator.pop(context);
    }

    final challenges = ref.watch(challengeProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeChallengesCount = challenges.where((challenge) {
      final endDate = challenge.startDate.add(
        Duration(days: challenge.duration),
      );
      return (challenge.startDate.isBefore(today) ||
              challenge.startDate.isAtSameMomentAs(today)) &&
          endDate.isAfter(today);
    }).length;

    final isChallengeLimitReached = activeChallengesCount >= 5;

    if (challengeToEdit == null &&
        isChallengeLimitReached &&
        creationMode.value == 'CHALLENGE') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        creationMode.value = 'HABIT';
      });
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          challengeToEdit != null
              ? 'Edit Mission'
              : (habitToEdit != null ? 'Edit Habit' : 'Create New'),
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // MODE TOGGLE
            if (challengeToEdit == null) ...[
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _modeToggleItem(
                        'HABIT',
                        creationMode.value == 'HABIT',
                        () => creationMode.value = 'HABIT',
                        colors,
                      ),
                    ),
                    if (!isChallengeLimitReached)
                      Expanded(
                        child: _modeToggleItem(
                          'CHALLENGE',
                          creationMode.value == 'CHALLENGE',
                          () => creationMode.value = 'CHALLENGE',
                          colors,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: context.h(3)),
            ],

            if (creationMode.value == 'HABIT') ...[
              _sectionHeader('HABIT IDENTITY', colors),
              _customTextField(
                controller: nameController,
                hintText: 'e.g. Morning Meditation',
                label: 'Habit Name',
                maxLength: 30,
                colors: colors,
              ),

              SizedBox(height: context.h(3)),

              _sectionHeader('CATEGORY', colors),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...categories.value.map(
                      (cat) => _categoryChip(
                        context,
                        cat['name'] as String,
                        cat['icon'] as IconData,
                        selectedCategory.value == cat['name'],
                        () {
                          selectedCategory.value = cat['name'] as String;
                          selectedIcon.value =
                              (cat['icon'] as IconData).codePoint;
                        },
                        colors,
                      ),
                    ),
                    _categoryChip(
                      context,
                      'Custom',
                      Icons.add,
                      false,
                      _showCustomCategoryDialog,
                      colors,
                    ),
                  ],
                ),
              ),

              SizedBox(height: context.h(3)),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader('FREQUENCY', colors),
                        _frequencyToggle(
                          context,
                          selectedFrequency.value,
                          (val) => selectedFrequency.value = val,
                          colors,
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
                        _sectionHeader('GOAL/TARGET', colors),
                        _goalInput(
                          context,
                          targetValue.value,
                          targetUnit.value,
                          (val) => targetValue.value = val,
                          colors,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.h(3)),

              _sectionHeader('HABIT DURATION', colors),
              _endDateSetter(
                context,
                endDate.value,
                (val) => endDate.value = val,
                colors,
              ),

              SizedBox(height: context.h(3)),

              _sectionHeader('PRIORITY LEVEL', colors),
              _prioritySelector(
                context,
                priority.value,
                (val) => priority.value = val,
                colors,
              ),

              SizedBox(height: context.h(3)),

              _sectionHeader('MOTIVATION NOTE', colors),
              _motivationField(noteController, colors),

              SizedBox(height: context.h(4)),

              _createHabitButton(context, handleCreateHabit, colors),

              SizedBox(height: context.h(5)),
            ] else ...[
              ..._buildChallengeForm(
                context,
                ref,
                chNameController,
                chDurationController,
                threatLevel,
                chConsequenceType,
                specificConsequence,
                roadmap,
                () => handleAcceptChallenge(
                  context,
                  ref,
                  chNameController,
                  chDurationController,
                  threatLevel,
                  chConsequenceType,
                  specificConsequence,
                  roadmap.value,
                ),
                colors,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          color: colors.textMuted,
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
    required AppColorScheme colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
              Text(
                '0/$maxLength',
                style: TextStyle(color: colors.textMuted, fontSize: 10),
              ),
            ],
          ),
          TextField(
            controller: controller,
            style: TextStyle(color: colors.textPrimary, fontSize: 18),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: colors.textMuted.withOpacity(0.4),
                fontSize: 18,
              ),
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
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colors.border.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.4),
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
              color: isSelected ? Colors.white : colors.textMuted,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textMuted,
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
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
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
                  color: isSel ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Text(
                  freq,
                  style: TextStyle(
                    color: isSel ? Colors.white : colors.textMuted,
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
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Container(
            height: 24,
            width: 1,
            color: colors.divider,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          Text(
            unit,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: colors.textMuted, size: 16),
        ],
      ),
    );
  }

  Widget _endDateSetter(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateChange,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'End Date',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'HABIT DURATION RANGE',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                onDateChange(DateTime.now().add(Duration(days: index + 1)));
              },
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index + 1));
                  final isSelected =
                      date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;
                  return Center(
                    child: Text(
                      "${date.day} ${_getMonth(date.month)} ${date.year}",
                      style: TextStyle(
                        color: isSelected
                            ? colors.primary
                            : colors.textMuted.withOpacity(0.4),
                        fontSize: isSelected ? 24 : 18,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
                childCount: 365,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _prioritySelector(
    BuildContext context,
    String selected,
    Function(String) onSelect,
    AppColorScheme colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: _priorityChip(
            'LOW',
            AppColors.lowPriorityColor,
            selected == 'LOW',
            () => onSelect('LOW'),
            colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _priorityChip(
            'MEDIUM',
            AppColors.mediumPriorityColor,
            selected == 'MEDIUM',
            () => onSelect('MEDIUM'),
            colors,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _priorityChip(
            'HIGH',
            AppColors.highPriorityColor,
            selected == 'HIGH',
            () => onSelect('HIGH'),
            colors,
          ),
        ),
      ],
    );
  }

  Widget _priorityChip(
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? color : colors.border.withOpacity(0.3),
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
                color: isSelected ? color : colors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motivationField(
    TextEditingController controller,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: "Define your 'Why'... Success is the only option.",
          hintStyle: TextStyle(
            color: colors.textMuted.withOpacity(0.4),
            fontSize: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _createHabitButton(
    BuildContext context,
    VoidCallback onTap,
    AppColorScheme colors,
  ) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  Widget _modeToggleItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textMuted,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  void handleAcceptChallenge(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController durationController,
    ValueNotifier<String> threatLevel,
    ValueNotifier<String> consequenceType,
    ValueNotifier<String> specificConsequence,
    List<ChallengeMilestone> roadmap,
  ) {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a mission identification name'),
        ),
      );
      return;
    }

    final duration = int.tryParse(durationController.text) ?? 30;

    if (challengeToEdit != null) {
      final updatedChallenge = challengeToEdit!.copyWith(
        name: nameController.text.toUpperCase(),
        duration: duration,
        threatLevel: threatLevel.value,
        consequenceType: consequenceType.value,
        specificConsequence: specificConsequence.value,
        roadmap: roadmap,
      );
      ref.read(challengeProvider.notifier).updateChallenge(updatedChallenge);
    } else {
      ref
          .read(challengeProvider.notifier)
          .addChallenge(
            name: nameController.text.toUpperCase(),
            duration: duration,
            threatLevel: threatLevel.value,
            consequenceType: consequenceType.value,
            specificConsequence: specificConsequence.value,
            startDate: DateTime.now(),
            roadmap: roadmap,
          );
    }

    Navigator.pop(context);
  }

  List<Widget> _buildChallengeForm(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController durationController,
    ValueNotifier<String> threatLevel,
    ValueNotifier<String> consequenceType,
    ValueNotifier<String> specificConsequence,
    ValueNotifier<List<ChallengeMilestone>> roadmap,
    VoidCallback onAccept,
    AppColorScheme colors,
  ) {
    return [
      _buildChSectionHeader('MISSION IDENTIFICATION', colors),
      _buildChLabel('CHALLENGE NAME', colors),
      _buildChTextField(nameController, 'E.G. NO-SURRENDER-MARCH', colors),
      const SizedBox(height: 20),
      _buildChLabel('DURATION (DAYS)', colors),
      _buildChTextField(
        durationController,
        '30',
        colors,
        keyboardType: TextInputType.number,
      ),

      const SizedBox(height: 30),
      _buildChSectionHeader('MISSION ROADMAP', colors),
      ...roadmap.value.map(
        (m) => _buildMilestoneTile(m, () {
          roadmap.value = roadmap.value
              .where((item) => item.id != m.id)
              .toList();
        }, colors),
      ),
      _buildAddMilestoneButton(() {
        _showAddMilestoneDialog(context, (m) {
          roadmap.value = [...roadmap.value, m];
        });
      }, colors),

      const SizedBox(height: 40),
      _buildChWarningCard(colors),
      const SizedBox(height: 20),
      _buildChAcceptButton(onAccept, colors),
      const SizedBox(height: 40),
    ];
  }

  Widget _buildChSectionHeader(String title, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: colors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChLabel(String text, AppColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChTextField(
    TextEditingController controller,
    String hint,
    AppColorScheme colors, {
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: colors.textMuted.withOpacity(0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChWarningCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.highPriorityColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.highPriorityColor.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.highPriorityColor,
            size: 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BROTHERHOOD WARNING',
                  style: TextStyle(
                    color: AppColors.highPriorityColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Once started, backing out has consequences. Your progress will be monitored by the brotherhood.',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChAcceptButton(VoidCallback onTap, AppColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 10,
          shadowColor: colors.primary.withOpacity(0.5),
        ),
        child: const Text(
          'ACCEPT THE CHALLENGE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneTile(
    ChallengeMilestone milestone,
    VoidCallback onRemove,
    AppColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${milestone.durationDays} Days • ${milestone.subtasks.length} Subtasks',
                  style: TextStyle(color: colors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }

  Widget _buildAddMilestoneButton(VoidCallback onTap, AppColorScheme colors) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: colors.primary, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'ADD MILESTONE',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMilestoneDialog(
    BuildContext context,
    Function(ChallengeMilestone) onAdded,
  ) {
    showDialog(
      context: context,
      builder: (context) => _MilestoneAddDialog(onAdded: onAdded),
    );
  }
}

class _MilestoneAddDialog extends HookWidget {
  final Function(ChallengeMilestone) onAdded;
  const _MilestoneAddDialog({required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final titleController = useTextEditingController();
    final descController = useTextEditingController();
    final durationController = useTextEditingController(text: '7');
    final subtaskController = useTextEditingController();
    final subtasks = useState<List<String>>([]);
    final editingIndex = useState<int?>(-1);
    final colors = Theme.of(context).appColors;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Milestone',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _dialogTextField(
              titleController,
              'Milestone Title (e.g. Phase 1)',
              colors,
            ),
            const SizedBox(height: 15),
            _dialogTextField(
              descController,
              'Description',
              colors,
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            _dialogTextField(
              durationController,
              'Duration (Days)',
              colors,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            Text(
              'SUBTASKS',
              style: TextStyle(
                color: colors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _dialogTextField(
                    subtaskController,
                    'Add subtask...',
                    colors,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    editingIndex.value != null && editingIndex.value! >= 0
                        ? Icons.check_circle
                        : Icons.add_circle,
                    color: colors.primary,
                  ),
                  onPressed: () {
                    if (subtaskController.text.isNotEmpty) {
                      if (editingIndex.value != null &&
                          editingIndex.value! >= 0) {
                        // Update existing subtask
                        final newList = List<String>.from(subtasks.value);
                        newList[editingIndex.value!] = subtaskController.text;
                        subtasks.value = newList;
                        editingIndex.value = -1;
                      } else {
                        // Add new subtask
                        subtasks.value = [
                          ...subtasks.value,
                          subtaskController.text,
                        ];
                      }
                      subtaskController.clear();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...subtasks.value.asMap().entries.map((entry) {
              final index = entry.key;
              final s = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      color: colors.textMuted,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: editingIndex.value == index
                            ? colors.primary
                            : Colors.blueAccent,
                        size: 14,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: () {
                        // Put the subtask text into the TextField for inline editing
                        subtaskController.text = s;
                        editingIndex.value = index;
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 14,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        final newList = List<String>.from(subtasks.value);
                        newList.removeAt(index);
                        subtasks.value = newList;
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      onAdded(
                        ChallengeMilestone(
                          id: const Uuid().v4(),
                          title: titleController.text,
                          description: descController.text,
                          durationDays:
                              int.tryParse(durationController.text) ?? 7,
                          subtasks: subtasks.value
                              .map(
                                (s) => ChallengeSubtask(
                                  id: const Uuid().v4(),
                                  title: s,
                                ),
                              )
                              .toList(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogTextField(
    TextEditingController controller,
    String hint,
    AppColorScheme colors, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: colors.textMuted.withOpacity(0.4),
          fontSize: 13,
        ),
        filled: true,
        fillColor: colors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _CustomCategoryDialog extends HookWidget {
  final Function(String, IconData) onAdded;

  const _CustomCategoryDialog({required this.onAdded});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final selectedIcon = useState(Icons.category);
    final colors = Theme.of(context).appColors;

    final icons = [
      Icons.star,
      Icons.favorite,
      Icons.work,
      Icons.school,
      Icons.fitness_center,
      Icons.sports_basketball,
      Icons.music_note,
      Icons.brush,
      Icons.code,
      Icons.camera_alt,
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.directions_run,
      Icons.directions_bike,
      Icons.flight,
      Icons.home,
      Icons.pets,
      Icons.book,
      Icons.event,
      Icons.access_time,
      Icons.lightbulb,
      Icons.money,
      Icons.account_balance,
      Icons.smartphone,
      Icons.tv,
      Icons.headset,
      Icons.videogame_asset,
      Icons.nature,
      Icons.pool,
    ];

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Custom Category',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: TextStyle(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Category Name',
                hintStyle: TextStyle(color: colors.textMuted.withOpacity(0.4)),
                filled: true,
                fillColor: colors.bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Icon',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final icon = icons[index];
                  final isSelected = selectedIcon.value == icon;
                  return GestureDetector(
                    onTap: () => selectedIcon.value = icon,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : colors.bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : colors.textMuted,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      onAdded(nameController.text, selectedIcon.value);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
