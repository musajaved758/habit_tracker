import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider for managing app theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
