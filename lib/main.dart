import 'package:flutter/material.dart';
import 'package:operation_brotherhood/core/utils/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:operation_brotherhood/core/services/hive_service.dart';
import 'package:operation_brotherhood/features/main_screen.dart';
import 'package:operation_brotherhood/core/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScreen(),
    );
  }
}
