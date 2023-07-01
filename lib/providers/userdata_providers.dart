import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';

final authProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final myInformationProvider = StreamProvider<UserData>((ref) {
  final auth = ref.watch(authProvider);
  final authUser = auth.asData!.value;
  final stream = FirebaseFirestore.instance
      .collection('users')
      .doc(authUser!.uid)
      .snapshots();
  return stream.map((snapshot) => UserData.fromFirestore(snapshot));
});

final myEventsProvider = StreamProvider<Map<DateTime, dynamic>>((ref) {
  final auth = ref.watch(authProvider);
  final authUser = auth.asData!.value;
  final stream = FirebaseFirestore.instance
      .collection('events')
      .doc(authUser!.uid)
      .snapshots();
  return stream.map((snapshot) => Map.fromIterables(
        Iterable.generate(snapshot.data()!.length, (index) {
          final key = snapshot.data()!.keys.elementAt(index);
          final year = int.parse(key.split('_')[0]);
          final month = int.parse(key.split('_')[1]);
          final day = int.parse(key.split('_')[2]);
          return DateTime.utc(year, month, day);
        }),
        snapshot.data()!.values,
      ));
});

final friendsInformationsProvider = FutureProvider<List<UserData>>((ref) async {
  final friendList = ref.watch(myInformationProvider).asData!.value.friendList;
  if (friendList.isEmpty) {
    return [];
  } else {
    final collection = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await collection.where('id', whereIn: friendList).get();
    return querySnapshot.docs
        .map((doc) => UserData.fromFirestore(doc))
        .toList();
  }
});

final friendsEventsProvider =
    FutureProvider<List<Map<DateTime, dynamic>>>((ref) async {
  final friendList = ref.watch(myInformationProvider).asData!.value.friendList;
  if (friendList.isEmpty) {
    return [];
  } else {
    final collection = FirebaseFirestore.instance.collection('events');
    final querySnapshot =
        await collection.where(FieldPath.documentId, whereIn: friendList).get();
    return querySnapshot.docs
        .map(
          (snapshot) => Map.fromIterables(
            Iterable.generate(snapshot.data().length, (index) {
              final key = snapshot.data().keys.elementAt(index);
              final year = int.parse(key.split('_')[0]);
              final month = int.parse(key.split('_')[1]);
              final day = int.parse(key.split('_')[2]);
              return DateTime.utc(year, month, day);
            }),
            snapshot.data().values,
          ),
        )
        .toList();
  }
});
