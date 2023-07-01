import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

final serchedUsersProvider =
    StateNotifierProvider<SerchedUsersNotifier, List<UserData>>(
        (ref) => SerchedUsersNotifier());

class SerchedUsersNotifier extends StateNotifier<List<UserData>> {
  SerchedUsersNotifier() : super([]);

  Future<void> makeSerchedUsers(String field) async {
    List<UserData> serchedUsers = [];
    await FirebaseFirestore.instance
        .collection('users')
        .where(
          'id',
          isEqualTo: field,
        )
        .get()
        .then((idValue) async {
      for (var element in idValue.docs) {
        serchedUsers.add(UserData.fromFirestore(element));
      }
      await FirebaseFirestore.instance
          .collection('users')
          .where(
            'name',
            isEqualTo: field,
          )
          .get()
          .then((nameValue) {
        for (var element in nameValue.docs) {
          serchedUsers.add(UserData.fromFirestore(element));
        }
        state = [...serchedUsers];
      });
    });
  }
}
