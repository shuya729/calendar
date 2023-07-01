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
        primarySwatch: Colors.pink,
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
    int numbersFriendsEvent = focusedFriendsEvents.length;
    for (var value in focusedFriendsEvents) {
      if (value.containsKey(DateTime.utc(day.year, day.month, day.day))) {
        numbersFriendsEvent--;
      }
    }
    final Widget eventMaker = Container(
      margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
      height: 9,
      width: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day)))
                ? const Color(0xff00214d).withOpacity(0.2)
                : const Color(0xff00ebc7).withOpacity(0.3),
      ),
    );
    if (numbersFriendsEvent == 0) {
      return const SizedBox(height: 18);
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
        height: 18,
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
        height: 18,
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
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day)))
                  ? const Color(0xff00214d).withOpacity(0.2)
                  : const Color(0xff00ebc7).withOpacity(0.3),
        ),
        child: Center(
          child: Text(
            "$numbersFriendsEvent",
            style: TextStyle(
              fontSize: 14,
              color: (myEvents
                      .containsKey(DateTime.utc(day.year, day.month, day.day)))
                  ? const Color(0xfffffffe)
                  : const Color(0xff00214d).withOpacity(0.8),
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
    const Color stroke = Color(0xff00214d);
    const Color main = Color(0xfffffffe);
    const Color highLight = Color(0xff00ebc7);
    const Color secondary = Color(0xffff5470);
    const Color tertiary = Color(0xfffde24f);

    // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final double areaWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;
    final ScrollController scrollController =
        ref.watch(scrollControllerProvider);
    final double deltaPosition = ref.watch(deltaPositionProvider);
    final DateTime focusedDay = ref.watch(focusedDayProvider);
    final DateTime? selectedDay = ref.watch(selectedDayProvider);
    final bool editmode = ref.watch(editmodeProvider);
    final List<Map<DateTime, dynamic>> focusedFriendsEvents =
        ref.watch(focusedFriendsEventsProvider);

    final int selectedIndex = ref.watch(selectedIndexProvider);
    final UserData myInformation =
        ref.watch(myInformationProvider).asData!.value;
    final List<UserData> friendsInformations =
        ref.watch(friendsInformationsProvider).asData!.value;
    final Map<DateTime, dynamic> myEvents =
        ref.watch(myEventsProvider).asData!.value;
    final List<Map<DateTime, dynamic>> friendsEvents =
        ref.watch(friendsEventsProvider).asData!.value;

    return Scaffold(
      // key: scaffoldKey,
      backgroundColor: secondary,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: secondary,
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                controller: scrollController,
                slivers: <Widget>[
                  SliverAppBar(
                    backgroundColor: secondary,
                    foregroundColor: stroke,
                    expandedHeight: areaHeight * 0.07,
                    toolbarHeight: areaHeight * 0.07,
                    titleSpacing: 0.0,
                    floating: true,
                    snap: true,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'ロゴ',
                            style: TextStyle(
                              fontSize: 22.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AddFriendScreen(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.person_add),
                              iconSize: 22.5,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications),
                              iconSize: 22.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: friendsInformations.length + 1,
                      (context, index) => GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          ref.read(selectedIndexProvider.notifier).state =
                              index;
                          scrollController.jumpTo(
                            areaHeight * 0.07 + areaHeight * 0.08 * index,
                          );
                          ref.read(deltaPositionProvider.notifier).state =
                              areaHeight * 0.37;
                          (index == 0)
                              ? ref
                                  .read(focusedFriendsEventsProvider.notifier)
                                  .state = [...friendsEvents]
                              : ref
                                  .read(focusedFriendsEventsProvider.notifier)
                                  .state = [friendsEvents[index - 1]];
                        },
                        child: Container(
                          height: areaHeight * 0.08,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircleAvatar(
                                    radius: areaHeight * 0.03,
                                    backgroundImage: CachedNetworkImageProvider(
                                      (index == 0)
                                          ? myInformation.imageUrl
                                          : friendsInformations[index - 1]
                                              .imageUrl,
                                    ),
                                  ),
                                  SizedBox(width: areaWidth * 0.02),
                                  (index == 0)
                                      ? Text(
                                          'マイページ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: stroke,
                                          ),
                                        )
                                      : Text(
                                          friendsInformations[index - 1].name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: stroke,
                                          ),
                                        ),
                                ],
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Text('プロック'),
                                    onTap: () {},
                                  ),
                                  PopupMenuItem(
                                    child: Text('フレンド解除'),
                                    onTap: () {},
                                  ),
                                ],
                                icon: Icon(Icons.more_vert),
                              ),
                              // IconButton(
                              //   icon:
                              //   color: stroke,
                              //   onPressed: () {},
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SliverToBoxAdapter(),
                  SliverFillRemaining(),
                ],
              ),
            ),
            Positioned(
              width: areaWidth,
              bottom: -areaHeight * 0.37,
              height: areaHeight * 0.92 +
                  deltaPosition.clamp(areaHeight * 0.0, areaHeight * 0.37),
              // alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  ref.read(deltaPositionProvider.notifier).state -=
                      details.delta.dy;
                },
                onVerticalDragEnd: (details) {
                  if (deltaPosition < areaHeight * 0.185) {
                    ref.read(deltaPositionProvider.notifier).state = 0;
                  } else {
                    ref.read(deltaPositionProvider.notifier).state =
                        areaHeight * 0.37;
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: areaHeight * 0.01,
                    horizontal: areaWidth * 0.05,
                  ),
                  decoration: ShapeDecoration(
                    color: main,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(areaHeight * 0.05),
                        topLeft: Radius.circular(areaHeight * 0.05),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: stroke.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TableCalendar(
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
                          headerPadding: EdgeInsets.all(0),
                          titleTextStyle: TextStyle(),
                          // decoration: BoxDecoration(color: Colors.blue),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: stroke,
                            fontSize: 13,
                          ),
                        ),
                        calendarBuilders: CalendarBuilders(
                          headerTitleBuilder: (context, day) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    "${day.year}年${day.month}月",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal,
                                      color: stroke,
                                    ),
                                  ),
                                ),
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
                                          color: stroke,
                                          size: 22.5,
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
                                          color: stroke,
                                          size: 22.5,
                                        ),
                                      ),
                              ],
                            );
                          },
                          dowBuilder: (_, day) {
                            if (day.weekday == DateTime.sunday) {
                              return const Center(
                                child: Text(
                                  "日",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            } else if (day.weekday == DateTime.saturday) {
                              return const Center(
                                child: Text(
                                  "土",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }
                            return null;
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
                                      margin: const EdgeInsets.all(3.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: main,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: (myEvents.containsKey(
                                                      DateTime.utc(day.year,
                                                          day.month, day.day)))
                                                  ? stroke.withOpacity(0.4)
                                                  : stroke,
                                            ),
                                          ),
                                          SizedBox(height: 18)
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(3.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: main,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: (myEvents.containsKey(
                                                    DateTime.utc(day.year,
                                                        day.month, day.day)))
                                                ? stroke.withOpacity(0.4)
                                                : stroke,
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
                                      margin: const EdgeInsets.all(3.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: main,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: (myEvents.containsKey(
                                                      DateTime.utc(day.year,
                                                          day.month, day.day)))
                                                  ? stroke.withOpacity(0.4)
                                                  : stroke,
                                            ),
                                          ),
                                          SizedBox(height: 18),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(1.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: tertiary,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: (myEvents.containsKey(
                                                    DateTime.utc(day.year,
                                                        day.month, day.day)))
                                                ? stroke.withOpacity(0.4)
                                                : stroke,
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
                                      margin: const EdgeInsets.all(3.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: tertiary.withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            day.day.toString(),
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              color: (myEvents.containsKey(
                                                          DateTime.utc(
                                                              day.year,
                                                              day.month,
                                                              day.day)) ||
                                                      focusedDay.month !=
                                                          day.month)
                                                  ? stroke.withOpacity(0.4)
                                                  : stroke,
                                            ),
                                          ),
                                          SizedBox(height: 18),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.all(3.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: tertiary.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: (myEvents.containsKey(
                                                        DateTime.utc(
                                                            day.year,
                                                            day.month,
                                                            day.day)) ||
                                                    focusedDay.month !=
                                                        day.month)
                                                ? stroke.withOpacity(0.4)
                                                : stroke,
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
                                  );
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: const EdgeInsets.all(3.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: main,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: stroke.withOpacity(0.4),
                                    ),
                                  ),
                                  SizedBox(height: 18),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: areaHeight * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "Users state",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: stroke,
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
                                      backgroundColor: main,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        (index == 0)
                                            ? myInformation.imageUrl
                                            : (selectedIndex == 0)
                                                ? friendsInformations[index - 1]
                                                    .imageUrl
                                                : [
                                                    friendsInformations[
                                                        selectedIndex - 1]
                                                  ][index - 1]
                                                    .imageUrl,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
          color: main,
          child: Column(
            children: [
              SizedBox(height: 40),
              Center(
                child: Text(
                  '設定',
                  style: TextStyle(
                    color: stroke,
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
