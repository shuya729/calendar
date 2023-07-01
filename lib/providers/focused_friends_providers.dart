import 'package:calendar/providers/other_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'userdata_providers.dart';

final focusedFriendsEventsProvider =
    StateProvider<List<Map<DateTime, dynamic>>>((ref) {
  final friendsEvents = ref.watch(friendsEventsProvider);
  return friendsEvents.when(
    data: (data) => data,
    error: (error, stackTrace) => [],
    loading: () => [],
  );
});

final focusedFriendsInformationsProvider =
    StateNotifierProvider<FocusedFriendsInformationsNotifier, List<UserData>>(
        (ref) {
  return FocusedFriendsInformationsNotifier(ref);
});

class FocusedFriendsInformationsNotifier extends StateNotifier<List<UserData>> {
  late StateNotifierProviderRef _ref;
  FocusedFriendsInformationsNotifier(StateNotifierProviderRef ref)
      : super(
          ref.watch(friendsInformationsProvider).when(
                data: (data) => data,
                error: (error, stackTrace) => [],
                loading: () => [],
              ),
        ) {
    _ref = ref;
  }

  void selectIndex(int index) {
    final friendsInformations =
        _ref.watch(friendsInformationsProvider).asData!.value;
    final friendsEvents = _ref.watch(friendsEventsProvider).asData!.value;

    _ref.read(deltaTopProvider.notifier).state = 0.0;
    if (index == 0) {
      _ref.read(focusedFriendsEventsProvider.notifier).state = [
        ...friendsEvents
      ];
      state = [...friendsInformations];
    } else {
      _ref.read(focusedFriendsEventsProvider.notifier).state = [
        friendsEvents[index - 1]
      ];
      state = [friendsInformations[index - 1]];
    }
  }
}
