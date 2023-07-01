import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/user_model.dart';
import 'pages/loading_screen.dart';
import 'pages/login_screen.dart';
import 'pages/my_account_screen.dart';
import '../pages/add_friend_screen.dart';
import 'providers/focused_friends_providers.dart';
import 'providers/other_providers.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
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

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  Widget _buildEventMaker(
    DateTime day,
    Map<DateTime, dynamic> myEvents,
    List<Map<DateTime, dynamic>> focusedFriendsEvents,
  ) {
    const Color onMain = Color(0xfffffffe);
    const Color strictMain = Color(0xFF748473);

    int numbersFriendsEvent = focusedFriendsEvents.length;

    for (var value in focusedFriendsEvents) {
      if (value.containsKey(DateTime.utc(day.year, day.month, day.day))) {
        numbersFriendsEvent--;
      }
    }
    final Widget eventMaker = Container(
      height: 7,
      width: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day)))
                ? onMain.withOpacity(0.3)
                : onMain.withOpacity(0.7),
      ),
    );
    if (numbersFriendsEvent == 0) {
      return const SizedBox(height: 17);
    } else if (numbersFriendsEvent == 1) {
      return SizedBox(
        height: 18,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              eventMaker,
            ],
          ),
        ),
      );
    } else if (numbersFriendsEvent == 2) {
      return SizedBox(
        height: 17,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              eventMaker,
              eventMaker,
            ],
          ),
        ),
      );
    } else if (numbersFriendsEvent == 3) {
      return SizedBox(
        height: 17,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              eventMaker,
              eventMaker,
              eventMaker,
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 17,
        width: 17,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day)))
                  ? onMain.withOpacity(0.3)
                  : onMain.withOpacity(0.7),
        ),
        child: Center(
          child: Text(
            "$numbersFriendsEvent",
            style: TextStyle(
              fontSize: 13,
              color: (myEvents
                      .containsKey(DateTime.utc(day.year, day.month, day.day)))
                  ? strictMain
                  : strictMain,
            ),
          ),
        ),
      );
    }
  }

  void _changeTheDayState(
    DateTime day,
    UserData myInformation,
    Map<DateTime, dynamic> myEvents,
  ) {
    final eventsRef =
        FirebaseFirestore.instance.collection('events').doc(myInformation.id);
    if (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day))) {
      eventsRef.update({
        '${day.year}_${day.month}_${day.day}': FieldValue.delete(),
      });
    } else {
      eventsRef.update({
        '${day.year}_${day.month}_${day.day}': '',
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color main = Color(0xff96ab94);
    const Color onMain = Color(0xfffffffe);
    const Color strictMain = Color(0xFF748473);
    const Color secondary = Color(0xfffffffe);
    const Color onSecondary = Color(0xff00214d);
    const Color tertiary = Color(0xff614a51);

    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final double areaWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;

    final double deltaTop = ref.watch(deltaTopProvider);
    final double deltaBottom = ref.watch(deltaBottomProvider);
    final DateTime focusedDay = ref.watch(focusedDayProvider);
    final DateTime? selectedDay = ref.watch(selectedDayProvider);
    final bool editmode = ref.watch(editmodeProvider);
    final List<Map<DateTime, dynamic>> focusedFriendsEvents =
        ref.watch(focusedFriendsEventsProvider);
    final List<UserData> focusedFriendsInformations =
        ref.watch(focusedFriendsInformationsProvider);
    final scaffoldKey = ref.watch(scaffoldKeyProvider);

    final UserData myInformation =
        ref.watch(myInformationProvider).asData!.value;
    final List<UserData> friendsInformations =
        ref.watch(friendsInformationsProvider).asData!.value;
    final Map<DateTime, dynamic> myEvents =
        ref.watch(myEventsProvider).asData!.value;
    final List<Map<DateTime, dynamic>> friendsEvents =
        ref.watch(friendsEventsProvider).asData!.value;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: secondary,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: main,
              child: Column(
                children: [
                  SizedBox(height: areaHeight * 0.1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2022, 6, 1),
                      lastDay: DateTime.utc(2024, 6, 1),
                      focusedDay: focusedDay,
                      calendarFormat: CalendarFormat.month,
                      locale: 'ja_JP',
                      sixWeekMonthsEnforced: true,
                      pageJumpingEnabled: true,
                      rowHeight: areaHeight * 0.07,
                      selectedDayPredicate: (day) {
                        return isSameDay(selectedDay, day);
                      },
                      onDaySelected: (onSelectedDay, onFocusedDay) {
                        if (!editmode) {
                          if (!isSameDay(selectedDay, onSelectedDay)) {
                            ref.read(selectedDayProvider.notifier).state =
                                onSelectedDay;
                            ref.read(focusedDayProvider.notifier).state =
                                onFocusedDay;
                          }
                        }
                        if (editmode == true) {
                          _changeTheDayState(
                            focusedDay,
                            myInformation,
                            myEvents,
                          );
                        }
                      },
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        formatButtonShowsNext: false,
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                        headerPadding: EdgeInsets.only(
                          top: 10,
                          bottom: 5,
                          left: 4,
                          right: 4,
                        ),
                        titleTextStyle: TextStyle(),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: onMain,
                          fontSize: 12,
                        ),
                        weekendStyle: TextStyle(
                          color: onMain,
                          fontSize: 12,
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        headerTitleBuilder: (context, day) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    "${day.year}年${day.month}月",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: onMain,
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(height: 18),
                                  (editmode)
                                      ? IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            ref
                                                .read(editmodeProvider.notifier)
                                                .state = false;
                                          },
                                          icon: Icon(
                                            Icons.check,
                                            color: onMain,
                                            size: 22,
                                          ),
                                        )
                                      : IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () {
                                            ref
                                                .read(editmodeProvider.notifier)
                                                .state = true;
                                          },
                                          icon: Icon(
                                            Icons.edit_calendar_outlined,
                                            color: onMain,
                                            size: 22,
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          );
                        },
                        defaultBuilder: (context, day, focusedDay) {
                          return (editmode)
                              ? GestureDetector(
                                  onTap: () {
                                    _changeTheDayState(
                                      day,
                                      myInformation,
                                      myEvents,
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: (myEvents.containsKey(
                                                    DateTime.utc(day.year,
                                                        day.month, day.day)))
                                                ? onMain.withOpacity(0.4)
                                                : onMain,
                                          ),
                                        ),
                                        SizedBox(height: 18)
                                      ],
                                    ),
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        day.day.toString(),
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          color: (myEvents.containsKey(
                                                  DateTime.utc(day.year,
                                                      day.month, day.day)))
                                              ? onMain.withOpacity(0.4)
                                              : onMain,
                                        ),
                                      ),
                                      _buildEventMaker(
                                        day,
                                        myEvents,
                                        focusedFriendsEvents,
                                      ),
                                    ],
                                  ),
                                );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return (editmode)
                              ? GestureDetector(
                                  onTap: () {
                                    _changeTheDayState(
                                      day,
                                      myInformation,
                                      myEvents,
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: (myEvents.containsKey(
                                                    DateTime.utc(day.year,
                                                        day.month, day.day)))
                                                ? onMain.withOpacity(0.4)
                                                : onMain,
                                          ),
                                        ),
                                        SizedBox(height: 18),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: strictMain,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: (myEvents.containsKey(
                                                    DateTime.utc(day.year,
                                                        day.month, day.day)))
                                                ? onMain.withOpacity(0.4)
                                                : onMain,
                                          ),
                                        ),
                                        _buildEventMaker(
                                          day,
                                          myEvents,
                                          focusedFriendsEvents,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                        todayBuilder: (context, day, focusedDay) {
                          return (editmode)
                              ? GestureDetector(
                                  onTap: () {
                                    _changeTheDayState(
                                      day,
                                      myInformation,
                                      myEvents,
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    color: strictMain.withOpacity(0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: (myEvents.containsKey(
                                                        DateTime.utc(
                                                            day.year,
                                                            day.month,
                                                            day.day)) ||
                                                    focusedDay.month !=
                                                        day.month)
                                                ? onMain.withOpacity(0.4)
                                                : onMain,
                                          ),
                                        ),
                                        SizedBox(height: 18),
                                      ],
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: strictMain.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            color: (myEvents.containsKey(
                                                        DateTime.utc(
                                                            day.year,
                                                            day.month,
                                                            day.day)) ||
                                                    focusedDay.month !=
                                                        day.month)
                                                ? onMain.withOpacity(0.4)
                                                : onMain,
                                          ),
                                        ),
                                        (focusedDay.month != day.month)
                                            ? SizedBox(height: 18)
                                            : _buildEventMaker(
                                                day,
                                                myEvents,
                                                focusedFriendsEvents,
                                              ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                        outsideBuilder: (context, day, focusedDay) {
                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: onMain.withOpacity(0.4),
                                  ),
                                ),
                                SizedBox(height: 17),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -areaHeight * 0.01,
              width: areaWidth,
              height: areaHeight * 0.1 + deltaTop.clamp(0, areaHeight * 0.19),
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  ref.read(deltaTopProvider.notifier).state += details.delta.dy;
                },
                onVerticalDragEnd: (details) {
                  if (deltaTop < areaHeight * 0.1) {
                    ref.read(deltaTopProvider.notifier).state = 0;
                  } else {
                    ref.read(deltaTopProvider.notifier).state =
                        areaHeight * 0.19;
                  }
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(areaHeight * 0.05),
                        bottomRight: Radius.circular(areaHeight * 0.05),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: (deltaTop < areaHeight * 0.12)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    ref.read(deltaTopProvider.notifier).state =
                                        areaHeight * 0.19;
                                  },
                                  icon: Icon(Icons.keyboard_arrow_down),
                                ),
                                CircleAvatar(
                                  radius: areaHeight * 0.03,
                                  backgroundImage: CachedNetworkImageProvider(
                                    (focusedFriendsInformations.length ==
                                            friendsInformations.length)
                                        ? myInformation.imageUrl
                                        : focusedFriendsInformations[0]
                                            .imageUrl,
                                  ),
                                ),
                                SizedBox(width: areaWidth * 0.02),
                                (focusedFriendsInformations.length ==
                                        friendsInformations.length)
                                    ? Text(
                                        'マイページ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: onSecondary,
                                        ),
                                      )
                                    : Text(
                                        focusedFriendsInformations[0].name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: onSecondary,
                                        ),
                                      ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: IconButton(
                                onPressed: () {
                                  scaffoldKey.currentState!.openEndDrawer();
                                },
                                icon: Icon(Icons.menu),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        ref
                                            .read(deltaTopProvider.notifier)
                                            .state = 0;
                                      },
                                      icon: Icon(Icons.keyboard_arrow_up),
                                    ),
                                    Text(
                                      'フレンド',
                                      style: TextStyle(
                                        color: onSecondary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.person_add),
                                  iconSize: 22,
                                  padding: EdgeInsets.only(right: 25),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddFriendScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Container(
                              height: areaHeight * 0.145,
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: friendsInformations.length + 1,
                                itemBuilder: (context, index) =>
                                    GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    ref
                                        .read(focusedFriendsInformationsProvider
                                            .notifier)
                                        .selectIndex(index);
                                  },
                                  child: Container(
                                    width: 65,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: onSecondary.withOpacity(0.1),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: areaHeight * 0.04,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            (index == 0)
                                                ? myInformation.imageUrl
                                                : friendsInformations[index - 1]
                                                    .imageUrl,
                                          ),
                                        ),
                                        SizedBox(height: areaHeight * 0.005),
                                        (index == 0)
                                            ? Text(
                                                'マイページ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: onSecondary,
                                                ),
                                              )
                                            : Text(
                                                friendsInformations[index - 1]
                                                    .name,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: onSecondary,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Positioned(
              width: areaWidth,
              bottom: 0,
              height: areaHeight * 0.3 +
                  deltaBottom.clamp(areaHeight * 0.0, areaHeight * 0.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  ref.read(deltaBottomProvider.notifier).state -=
                      details.delta.dy;
                },
                onVerticalDragEnd: (details) {},
                child: Container(
                  padding: EdgeInsets.only(
                    top: areaHeight * 0.03,
                    left: areaWidth * 0.05,
                    right: areaWidth * 0.05,
                  ),
                  decoration: ShapeDecoration(
                    color: secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(areaHeight * 0.05),
                        topRight: Radius.circular(areaHeight * 0.05),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            "予定のないフレンド",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: areaHeight * 0.1,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: focusedFriendsEvents.length + 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: areaHeight * 0.005,
                                right: areaHeight * 0.005,
                              ),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  (index == 0)
                                      ? (myEvents.containsKey(DateTime.utc(
                                              focusedDay.year,
                                              focusedDay.month,
                                              focusedDay.day)))
                                          ? main.withOpacity(0.6)
                                          : main.withOpacity(0.0)
                                      : (focusedFriendsEvents[index - 1]
                                              .containsKey(DateTime.utc(
                                                  focusedDay.year,
                                                  focusedDay.month,
                                                  focusedDay.day)))
                                          ? main.withOpacity(0.6)
                                          : main.withOpacity(0.0),
                                  BlendMode.srcATop,
                                ),
                                child: CircleAvatar(
                                  radius: areaHeight * 0.03,
                                  backgroundImage: CachedNetworkImageProvider(
                                    (index == 0)
                                        ? myInformation.imageUrl
                                        : focusedFriendsInformations[index - 1]
                                            .imageUrl,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Spacer(),
                      Container(width: 320, height: 50, color: Colors.blue),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        child: Container(
          color: secondary,
          child: Column(
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  '設定',
                  style: TextStyle(
                    color: onSecondary,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(height: 40),
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    title: const Text('プロフィール'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAccountScreen(myInformation: myInformation),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('ログアウト'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MyApp(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('退会'),
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('退会しますか？'),
                            actions: [
                              TextButton(
                                child: Text('キャンセル'),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const MyApp(),
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                child: Text('退会'),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('events')
                                      .doc(myInformation.id)
                                      .delete();
                                  await FirebaseStorage.instance
                                      .ref('users/${myInformation.id}')
                                      .delete();
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(myInformation.id)
                                      .delete();
                                  await FirebaseAuth.instance.currentUser!
                                      .delete();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const MyApp(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
