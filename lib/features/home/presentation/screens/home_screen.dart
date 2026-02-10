import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:iron_mind/features/home/presentation/widgets/habit_list_view.dart';
import 'package:iron_mind/core/providers/app_providers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colors = Theme.of(context).appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Start collapsed (showing only week view)
    final scrollController = ScrollController(initialScrollOffset: 260);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: colors.bg,
        body: SafeArea(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final offset = notification.metrics.pixels;
                final maxScroll = 260.0;
                // When user scrolls up towards collapsed state and date is not today,
                // snap selectedDate to today so the week strip shows current week
                if (offset > maxScroll * 0.7) {
                  final now = DateTime.now();
                  final current = ref.read(selectedDateProvider);
                  final isToday =
                      now.day == current.day &&
                      now.month == current.month &&
                      now.year == current.year;
                  if (!isToday) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(selectedDateProvider.notifier).state = now;
                    });
                  }
                }
              }
              return false;
            },
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CalendarHeaderDelegate(
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      ref.read(selectedDateProvider.notifier).state = date;
                    },
                    onTodayPressed: () {
                      ref.read(selectedDateProvider.notifier).state =
                          DateTime.now();
                    },
                    colors: colors,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: DailySummaryCard(selectedDate: selectedDate),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: HabitListView(selectedDate: selectedDate),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onTodayPressed;
  final AppColorScheme colors;

  _CalendarHeaderDelegate({
    required this.selectedDate,
    required this.onDateSelected,
    required this.onTodayPressed,
    required this.colors,
  });

  @override
  double get minExtent => 110.0; // Reduced from 140
  @override
  double get maxExtent => 400.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final isToday =
        DateTime.now().day == selectedDate.day &&
        DateTime.now().month == selectedDate.month &&
        DateTime.now().year == selectedDate.year;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        boxShadow: progress > 0.8
            ? [
                BoxShadow(
                  color: colors.border.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Header Row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onTodayPressed,
                  child: Row(
                    children: [
                      Text(
                        DateFormat(
                          'MMMM yyyy',
                        ).format(selectedDate).toUpperCase(),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (!isToday) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "TODAY",
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (progress < 0.5)
                  Row(
                    children: [
                      _headerIconButton(
                        Icons.chevron_left,
                        () => onDateSelected(
                          DateTime(
                            selectedDate.year,
                            selectedDate.month - 1,
                            1,
                          ),
                        ),
                      ),
                      _headerIconButton(
                        Icons.chevron_right,
                        () => onDateSelected(
                          DateTime(
                            selectedDate.year,
                            selectedDate.month + 1,
                            1,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Calendar Body ──
          Expanded(
            child: progress > 0.8
                ? _WeekStrip(
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                    colors: colors,
                  )
                : Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: IgnorePointer(
                      ignoring: progress > 0.5,
                      child: _MonthCalendar(
                        selectedDate: selectedDate,
                        onDateSelected: onDateSelected,
                        colors: colors,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: colors.textSecondary, size: 22),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CalendarHeaderDelegate oldDelegate) {
    return oldDelegate.selectedDate != selectedDate ||
        oldDelegate.colors != colors;
  }
}

// ── Rounded-box Week Strip (collapsed view) ──
class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final AppColorScheme colors;

  const _WeekStrip({
    required this.selectedDate,
    required this.onDateSelected,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // Get the week containing selectedDate (Mon-Sun)
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          return Expanded(
            child: _DayCard(
              date: date,
              selectedDate: selectedDate,
              onTap: () => onDateSelected(date),
              colors: colors,
              compact: true,
            ),
          );
        }),
      ),
    );
  }
}

// ── Full Month Calendar (expanded view) ──
class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final AppColorScheme colors;

  const _MonthCalendar({
    required this.selectedDate,
    required this.onDateSelected,
    required this.colors,
  });
  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      selectedDate.year,
      selectedDate.month,
    );
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun

    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Column(
      children: [
        // Day-of-week headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Day grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                mainAxisSpacing: 6,
                crossAxisSpacing: 4,
              ),
              itemCount: daysInMonth + firstWeekday - 1,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  return const SizedBox();
                }
                final day = index - (firstWeekday - 1) + 1;
                final date = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  day,
                );
                return _DayCard(
                  date: date,
                  selectedDate: selectedDate,
                  onTap: () => onDateSelected(date),
                  colors: colors,
                  compact: false,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Individual Day Card (rounded box) ──
class _DayCard extends StatelessWidget {
  final DateTime date;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final bool compact;

  const _DayCard({
    required this.date,
    required this.selectedDate,
    required this.onTap,
    required this.colors,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;
    final now = DateTime.now();
    final isToday =
        date.day == now.day && date.month == now.month && date.year == now.year;

    // Colors
    Color bgColor;
    Color textColor;
    Color dayNameColor;

    if (isSelected) {
      bgColor = colors.calendarSelectedBg;
      textColor = colors.calendarSelectedText;
      dayNameColor = colors.calendarSelectedText.withOpacity(0.8);
    } else if (isToday) {
      bgColor = colors.primary.withOpacity(0.12);
      textColor = colors.primary;
      dayNameColor = colors.primary.withOpacity(0.7);
    } else {
      bgColor = colors.calendarDayBg;
      textColor = colors.calendarDayText;
      dayNameColor = colors.textMuted;
    }

    final dayName = DateFormat('E').format(date).toUpperCase().substring(0, 3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: compact ? 2 : 2,
          vertical: compact ? 2 : 2,
        ),
        padding: EdgeInsets.symmetric(vertical: compact ? 4 : 0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(compact ? 12 : 14),
          border: isToday && !isSelected
              ? Border.all(color: colors.calendarTodayBorder, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: TextStyle(
                color: dayNameColor,
                fontSize: compact ? 9 : 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: compact ? 2 : 2),
            Text(
              '${date.day}',
              style: TextStyle(
                color: textColor,
                fontSize: compact ? 14 : 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
