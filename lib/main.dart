import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'pages/loading_screen.dart';
import 'pages/login_screen.dart';
import 'pages/main_screen.dart';
import 'providers/userdata_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting().then(
    (_) => runApp(
      const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FirebaseAuth.instance.signOut();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: (ref.watch(authProvider).value == null)
          ? const LoginScreen()
          : ref.watch(myInformationProvider).when(
                error: (error, stackTrace) => const LoadingWidget(),
                loading: () => const LoadingWidget(),
                data: (myInformation) => ref.watch(myEventsProvider).when(
                      error: (error, stackTrace) => const LoadingWidget(),
                      loading: () => const LoadingWidget(),
                      data: (myEvents) => ref
                          .watch(friendsInformationsProvider)
                          .when(
                            error: (error, stackTrace) => const LoadingWidget(),
                            loading: () => const LoadingWidget(),
                            data: (friendsInformations) => ref
                                .watch(friendsEventsProvider)
                                .when(
                                  error: (error, stackTrace) =>
                                      const LoadingWidget(),
                                  loading: () => const LoadingWidget(),
                                  data: (friendsEvents) => const MainScreen(),
                                ),
                          ),
                    ),
              ),
    );
  }
}
