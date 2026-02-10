import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:iron_mind/core/utils/colors.dart';
import 'package:iron_mind/features/intel/presentation/providers/stats_provider.dart';

class IntelScreen extends HookConsumerWidget {
  const IntelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedView = useState('CHALLENGES');
    final colors = Theme.of(context).appColors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'PROGRESS',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildToggle(selectedView, colors),
          Expanded(
            child: selectedView.value == 'CHALLENGES'
                ? const _ChallengesView()
                : const _HabitsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    ValueNotifier<String> selectedView,
    AppColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: _toggleItem(
                'CHALLENGES',
                selectedView.value == 'CHALLENGES',
                () => selectedView.value = 'CHALLENGES',
                colors,
              ),
            ),
            Expanded(
              child: _toggleItem(
                'HABITS',
                selectedView.value == 'HABITS',
                () => selectedView.value = 'HABITS',
                colors,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleItem(
    String label,
    bool isSelected,
    VoidCallback onTap,
    AppColorScheme colors,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _ChallengesView extends HookConsumerWidget {
  const _ChallengesView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(challengeStatsProvider);
    final colors = Theme.of(context).appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('OVERALL CHALLENGE PROGRESS', colors),
          const SizedBox(height: 20),
          _buildRadialProgress(stats, colors),
          const SizedBox(height: 40),
          _sectionHeader('STREAK & CONSISTENCY', colors),
          const SizedBox(height: 20),
          _buildConsistencyInsight(stats, colors),
          const SizedBox(height: 40),
          _sectionHeader('PROGRESS OVER TIME', colors),
          const SizedBox(height: 20),
          _buildProgressChart(stats.completionHistory, colors),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRadialProgress(
    ChallengeIntelStats stats,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 45,
                    sections: [
                      PieChartSectionData(
                        value: stats.overallCompletionRate * 100,
                        color: colors.primary,
                        radius: 12,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (1 - stats.overallCompletionRate) * 100,
                        color: colors.progressBarBg,
                        radius: 10,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(stats.overallCompletionRate * 100).toInt()}%',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: TextStyle(color: colors.textMuted, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statRow(
                  'TOTAL',
                  stats.totalChallenges.toString(),
                  colors.textPrimary,
                  colors,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'COMPLETED',
                  stats.completedChallenges.toString(),
                  colors.primary,
                  colors,
                ),
                const SizedBox(height: 12),
                _statRow(
                  'ONGOING',
                  stats.ongoingChallenges.toString(),
                  colors.accent,
                  colors,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(
    String label,
    String value,
    Color valueColor,
    AppColorScheme colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(
    Map<DateTime, int> history,
    AppColorScheme colors,
  ) {
    final sortedDates = history.keys.toList()..sort();
    final dataPoints = sortedDates.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), history[e.value]!.toDouble());
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints,
              isCurved: true,
              color: colors.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistencyInsight(
    ChallengeIntelStats stats,
    AppColorScheme colors,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(now).toUpperCase(),
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + (startingWeekday - 1),
            itemBuilder: (context, index) {
              if (index < startingWeekday - 1) {
                return const SizedBox();
              }
              final day = index - (startingWeekday - 1) + 1;
              final date = DateTime(now.year, now.month, day);
              final count = stats.monthlyProgress[date] ?? 0;
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
              final isFuture = date.isAfter(now);

              Color bgColor = colors.progressBarBg;
              Color textColor = colors.textMuted;

              if (!isFuture) {
                if (count > 0) {
                  bgColor = colors.primary;
                  textColor = Colors.white;
                } else if (date.isBefore(
                  DateTime(now.year, now.month, now.day),
                )) {
                  bgColor = AppColors.highPriorityColor.withOpacity(0.2);
                  textColor = AppColors.highPriorityColor;
                }
              }

              if (isToday) {
                if (count == 0) {
                  bgColor = colors.primary.withOpacity(0.2);
                  textColor = colors.primary;
                }
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: colors.primary, width: 1)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$day',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HabitsView extends HookConsumerWidget {
  const _HabitsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider);
    final colors = Theme.of(context).appColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('HABIT COMPLETION OVERVIEW', colors),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'TOTAL',
                  stats.totalHabits.toString(),
                  colors.accent,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'DONE TODAY',
                  stats.completedToday.toString(),
                  colors.primary,
                  colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'MISSED',
                  stats.missedToday.toString(),
                  AppColors.highPriorityColor,
                  colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _sectionHeader('DAILY HABIT TREND', colors),
          const SizedBox(height: 20),
          _buildWeeklyBarChart(stats.weeklyTrend, colors),
          const SizedBox(height: 40),
          _sectionHeader('HABIT-WISE PROGRESS', colors),
          const SizedBox(height: 20),
          ...stats.habitDetails.map((h) => _buildHabitProgress(h, colors)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _miniStat(
    String label,
    String value,
    Color color,
    AppColorScheme colors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(
    Map<DateTime, int> weeklyTrend,
    AppColorScheme colors,
  ) {
    final sortedDates = weeklyTrend.keys.toList()..sort();
    final barGroups = sortedDates.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: weeklyTrend[e.value]!.toDouble(),
            color: colors.primary,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = sortedDates[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date)[0],
                      style: TextStyle(color: colors.textMuted, fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildHabitProgress(HabitDetailStats detail, AppColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SUCCESS RATE: ${(detail.completionRate * 100).toInt()}%',
                  style: TextStyle(color: colors.textMuted, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${detail.currentStreak}',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'STREAK',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _sectionHeader(String title, AppColorScheme colors) {
  return Text(
    title,
    style: TextStyle(
      color: colors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  );
}
