import 'package:calendar/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'userdata_providers.dart';

// final scrollControllerProvider =
//     Provider.autoDispose<ScrollController>((ref) => ScrollController());

final deltaTopProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final deltaBottomProvider = StateProvider.autoDispose<double>((ref) => 0.0);

final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);

final editmodeProvider = StateProvider<bool>((ref) => false);

// final selectedIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

final scaffoldKeyProvider =
    Provider<GlobalKey<ScaffoldState>>((ref) => GlobalKey<ScaffoldState>());
