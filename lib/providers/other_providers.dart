import 'package:flutter_riverpod/flutter_riverpod.dart';

final deltaTopProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final deltaBottomProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final editmodeProvider = StateProvider<bool>((ref) => false);

// final selectedIndexProvider = StateProvider.autoDispose<int>((ref) => 0);