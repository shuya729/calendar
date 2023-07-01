import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'userdata_providers.dart';

final scrollControllerProvider =
    Provider.autoDispose<ScrollController>((ref) => ScrollController());

final deltaPositionProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final editmodeProvider = StateProvider<bool>((ref) => false);

final selectedIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

final focusedFriendsEventsProvider =
    StateProvider<List<Map<DateTime, dynamic>>>((ref) {
  final friendsEvents = ref.watch(friendsEventsProvider);
  return friendsEvents.when(
      data: (data) => data,
      error: (error, stackTrace) => [],
      loading: () => []);
});
