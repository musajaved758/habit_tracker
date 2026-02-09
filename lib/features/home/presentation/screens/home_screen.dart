import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:operation_brotherhood/core/utils/colors.dart';
import 'package:operation_brotherhood/features/home/presentation/widgets/daily_summary_card.dart';
import 'package:operation_brotherhood/features/home/presentation/widgets/habit_list_view.dart';
import 'package:operation_brotherhood/features/home/presentation/widgets/time_line_widget.dart';
import 'package:operation_brotherhood/core/providers/app_providers.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final bool isActuallyToday = isToday(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.habitBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, selectedDate, isActuallyToday),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    sliver: SliverToBoxAdapter(
                      child: TimeLineWidget(
                        selectedDate: selectedDate,
                        onDateChange: (date) {
                          ref.read(selectedDateProvider.notifier).state = date;
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: DailySummaryCard(selectedDate: selectedDate),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 15)),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: HabitListView(selectedDate: selectedDate),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    bool isActuallyToday,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isActuallyToday)
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HELLO, BROTHER',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your Tasks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: () {
                ref.read(selectedDateProvider.notifier).state = DateTime.now();
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.habitPrimary),
              label: const Text(
                "Today's Tasks →",
                style: TextStyle(
                  color: AppColors.habitPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.habitPrimary.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          CircleAvatar(
            backgroundColor: AppColors.habitSurface,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
