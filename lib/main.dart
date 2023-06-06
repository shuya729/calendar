import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/user_model.dart';
import 'pages/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting()
      .then((_) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // home: const MainScreen(),
      home: (ref.watch(authenticationProvider).value == null)
          ? const LoginScreen()
          : const MainScreen(),
    );
  }
}

final deltaPositionProvider = StateProvider<double>((ref) => 0.0);
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedDayProvider = StateProvider<DateTime?>((ref) => null);
final editmodeProvider = StateProvider<bool>((ref) => false);
final authenticationProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());
// final myInformationProvider = StateProvider<UserData>((ref) {
//   UserData myInformation = UserData(
//     id: "",
//     name: "",
//     imageUrl: "",
//     freindLidt: [],
//   );
//   FirebaseFirestore.instance
//       .collection('users/${ref.watch(authenticationProvider).value?.uid}')
//       .doc('information')
//       .snapshots()
//       .listen((value) {
//     myInformation = UserData.fromFirestore(value);
//   });
//   return myInformation;
// });
// final friendsInformationProvider = Provider<List<UserData>>((ref) {
//   List<UserData> friends = [];
//   final myInformation = ref.watch(myInformationProvider);
//   for (String myId in myInformation.freindLidt) {
//     FirebaseFirestore.instance.collection('users/$myId').doc('information').snapshots().listen(
//       (friendId) {
//         friends.add(UserData.fromFirestore(friendId));
//       },
//       onError: (e) {
//         print(e);
//       },
//     );
//   }
//   return friends;
// });

// final myEventsProvider = Provider<Map<DateTime, dynamic>>((ref) {
//   Map<DateTime, String> myEvents = {};
//   final focusedDay = ref.watch(focusedDayProvider);
//   // final daysNumber = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
//   final myInformation = ref.watch(myInformationProvider);
//   FirebaseFirestore.instance
//       .collection(
//           'users/${myInformation.id}/dateData/${focusedDay.year}')
//       .doc('${focusedDay.month}')
//       .snapshots()
//       .listen((eventMap) {
//     eventMap.data()?.forEach((key, value) {
//       myEvents[
//               DateTime.utc(focusedDay.year, focusedDay.month, int.parse(key))] =
//           value;
//     });
//   });
//   return myEvents;
// });
// final friendsEventsProvider =
//     Provider<Map<String, Map<DateTime, dynamic>>>((ref) {
//   Map<String, Map<DateTime, dynamic>> friendsEvents = {};
//   final focusedDay = ref.watch(focusedDayProvider);
//   // final daysNumber = DateTime(focusedDay.year, focusedDay.month + 1, 0).day;
//   final friendsInformation = ref.watch(friendsInformationProvider);
//   for (UserData friend in friendsInformation) {
//     Map<DateTime, dynamic> friendEvents = {};
//     FirebaseFirestore.instance
//         .collection(
//             'users/${friend.id}/dateData/${focusedDay.year}')
//         .doc('${focusedDay.month}')
//         .snapshots()
//         .listen((eventMap) {
//       eventMap.data()?.forEach((key, value) {
//         friendEvents[DateTime.utc(
//             focusedDay.year, focusedDay.month, int.parse(key))] = value;
//       });
//     });
//     friendsEvents.addAll({friend.id: friendEvents});
//   }
//   return friendsEvents;
// });

//仮のprovier
final myInformationProvider = Provider<UserData>((ref) {
  return UserData(
    id: "my",
    name: "my",
    imageUrl: 'https://picsum.photos/seed/1/200/300'
        '?grayscale&blur=2',
    freindLidt: [
      'user1',
      'user2',
      'user3',
      'user4',
      'user5',
      'user6',
    ],
  );
});

final friendsInformationProvider = StateProvider<List<UserData>>((ref) {
  final UserData user1 = UserData(
    id: "user1",
    name: "user1",
    imageUrl: 'https://picsum.photos/seed/2/200/300',
    freindLidt: [
      'my',
    ],
  );
  final UserData user2 = UserData(
    id: "user2",
    name: "user2",
    imageUrl: 'https://picsum.photos/seed/3/200/300',
    freindLidt: [
      'my',
    ],
  );
  final UserData user3 = UserData(
    id: "user3",
    name: "user3",
    imageUrl: 'https://picsum.photos/seed/4/200/300',
    freindLidt: [
      'my',
    ],
  );
  final UserData user4 = UserData(
    id: "user4",
    name: "user4",
    imageUrl: 'https://picsum.photos/seed/5/200/300',
    freindLidt: [
      'my',
    ],
  );
  final UserData user5 = UserData(
    id: "user5",
    name: "user5",
    imageUrl: 'https://picsum.photos/seed/6/200/300',
    freindLidt: [
      'my',
    ],
  );
  final UserData user6 = UserData(
    id: "user6",
    name: "user6",
    imageUrl: 'https://picsum.photos/seed/7/200/300',
    freindLidt: [
      'my',
    ],
  );
  return [
    user1,
    user2,
    user3,
    user4,
    user5,
    user6,
  ];
});

final myEventsProvider = Provider<Map<DateTime, dynamic>>((ref) {
  Map<DateTime, dynamic> myEvents = {};
  for (int i = 0; i < 30; i++) {
    if (i % 4 == 0) {
      myEvents[DateTime.utc(2023, 6, i + 1)] = "";
    }
  }
  return myEvents;
});

final friendsEventsProvider =
    Provider<Map<String, Map<DateTime, dynamic>>>((ref) {
  Map<DateTime, String?> user1EventList = {};
  Map<DateTime, String?> user2EventList = {};
  Map<DateTime, String?> user3EventList = {};
  Map<DateTime, String?> user4EventList = {};
  Map<DateTime, String?> user5EventList = {};
  Map<DateTime, String?> user6EventList = {};
  for (int i = 0; i < 30; i++) {
    if (i % 3 == 0) {
      user1EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
    if (i % 4 == 0) {
      user2EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
    if (i % 7 == 0) {
      user3EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
    if (i % 9 == 0) {
      user4EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
    if (i % 12 == 0) {
      user5EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
    if (i % 24 == 0) {
      user6EventList[DateTime.utc(2023, 6, i + 1)] = "";
    }
  }
  return {
    'user1': user1EventList,
    'user2': user2EventList,
    'user3': user3EventList,
    'user4': user4EventList,
    'user5': user5EventList,
    'user6': user6EventList,
  };
});

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  Widget _buildEventMaker(WidgetRef ref, DateTime day) {
    final _myEvents = ref.watch(myEventsProvider);
    final _friendsEvents = ref.watch(friendsEventsProvider);
    int _numbersFriendsEvent = _friendsEvents.length;
    _friendsEvents.forEach((key, value) {
      if (value.containsKey(DateTime.utc(day.year, day.month, day.day))) {
        _numbersFriendsEvent--;
      }
    });
    final Widget eventMaker = Container(
      margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
      height: 10,
      width: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            (_myEvents.containsKey(DateTime.utc(day.year, day.month, day.day)))
                ? Colors.black26
                : Color(0xffa6d1c4),
      ),
    );
    if (_numbersFriendsEvent == 0) {
      return SizedBox.shrink();
    } else if (_numbersFriendsEvent == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          eventMaker,
        ],
      );
    } else if (_numbersFriendsEvent == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          eventMaker,
          eventMaker,
        ],
      );
    } else if (_numbersFriendsEvent == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          eventMaker,
          eventMaker,
          eventMaker,
        ],
      );
    } else {
      return Container(
        margin: EdgeInsets.only(top: 3.0),
        height: 18,
        width: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (_myEvents
                  .containsKey(DateTime.utc(day.year, day.month, day.day)))
              ? Colors.black26
              : Color(0xffa6d1c4),
        ),
        child: Center(
          child: Text(
            "${_numbersFriendsEvent}",
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  void _changeTheDayState(WidgetRef ref, DateTime day) {
    final myInformation = ref.watch(myInformationProvider);
    final myEvents = ref.watch(myEventsProvider);
    final eventsRef = FirebaseFirestore.instance
        .collection('users/${myInformation.id}/dateDate/${day.year}')
        .doc('${day.month}');
    if (myEvents.containsKey(DateTime.utc(day.year, day.month, day.day))) {
      eventsRef.update({
        '${day.day}': FieldValue.delete(),
      });
    } else {
      eventsRef.set({
        '${day.day}': '',
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final double areaWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;
    final double _deltaPosition = ref.watch(deltaPositionProvider);
    final DateTime _focusedDay = ref.watch(focusedDayProvider);
    final DateTime? _selectedDay = ref.watch(selectedDayProvider);
    final bool _editmode = ref.watch(editmodeProvider);
    final UserData _myInformation = ref.watch(myInformationProvider);
    final List<UserData> _friendsInformation =
        ref.watch(friendsInformationProvider);
    final Map<DateTime, dynamic> _myEvents = ref.watch(myEventsProvider);
    final Map<String, Map<DateTime, dynamic>> _friendsEvents =
        ref.watch(friendsEventsProvider);

    return Scaffold(
      backgroundColor: Color(0xffa6d1c4),
      body: SafeArea(
        child: Stack(
          // alignment: ,
          fit: StackFit.expand,
          // clipBehavior: ,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: areaWidth * 0.02,
              ),
              color: Color(0xffa6d1c4), //subColor 0xfffdce31
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: areaHeight * 0.005),
                  Container(
                    height: areaHeight * 0.14,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _friendsInformation.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: areaHeight * 0.01,
                            left: areaHeight * 0.01,
                            right: areaHeight * 0.01,
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: areaHeight * 0.045,
                                backgroundImage: NetworkImage(
                                  '${_friendsInformation[index].imageUrl}',
                                ),
                              ),
                              SizedBox(height: areaHeight * 0.005),
                              Text(
                                '${_friendsInformation[index].name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: areaHeight * 0.02),
                  Opacity(
                    opacity: ((_deltaPosition - areaHeight * 0.11) /
                            (areaHeight * 0.11))
                        .clamp(0.0, 1.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.person_add),
                              iconSize: areaHeight * 0.05,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications),
                              iconSize: areaHeight * 0.05,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.settings),
                              iconSize: areaHeight * 0.05,
                            )
                          ],
                        ),
                        SizedBox(height: areaHeight * 0.03),
                        Center(
                          child: Text(
                            "ロゴ",
                            style: TextStyle(
                                fontSize: 40, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  ref.read(deltaPositionProvider.notifier).state +=
                      details.delta.dy;
                },
                onVerticalDragEnd: (details) {
                  if (_deltaPosition < areaHeight * 0.11) {
                    ref.read(deltaPositionProvider.notifier).state = 0;
                  } else {
                    ref.read(deltaPositionProvider.notifier).state =
                        areaHeight * 0.22;
                  }
                },
                child: Container(
                  height: (areaHeight * 0.85 -
                      _deltaPosition.clamp(areaHeight * 0.0,
                          areaHeight * 0.22)), // (areaHeight * 0.22)
                  padding: EdgeInsets.symmetric(
                    vertical: areaHeight * 0.005,
                    horizontal: areaWidth * 0.05,
                  ),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(areaHeight * 0.05),
                        topLeft: Radius.circular(areaHeight * 0.05),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_focusedDay.year}年${_focusedDay.month}月",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.normal),
                          ),
                          (_editmode)
                              ? IconButton(
                                  onPressed: () {
                                    ref.read(editmodeProvider.notifier).state =
                                        false;
                                  },
                                  icon: Icon(Icons.check),
                                )
                              : IconButton(
                                  onPressed: () {
                                    ref.read(editmodeProvider.notifier).state =
                                        true;
                                  },
                                  icon: Icon(Icons.edit_calendar_outlined),
                                ),
                        ],
                      ),
                      SizedBox(height: areaHeight * 0.01),
                      TableCalendar(
                        firstDay: DateTime.utc(2022, 6, 1),
                        lastDay: DateTime.utc(2024, 6, 1),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
                        locale: 'ja_JP',
                        headerVisible: false,
                        sixWeekMonthsEnforced: true,
                        rowHeight: areaHeight * 0.08,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            ref.read(selectedDayProvider.notifier).state =
                                selectedDay;
                            ref.read(focusedDayProvider.notifier).state =
                                focusedDay;
                          }
                          if (_editmode == true) {
                            _changeTheDayState(ref, focusedDay);
                          }
                        },
                        // onPageChanged: (focusedDay) {},
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(3.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: (_myEvents.containsKey(DateTime.utc(
                                        day.year, day.month, day.day)))
                                    ? Border.all(
                                        color: Colors.black26,
                                        width: 0.8,
                                        style: BorderStyle.solid,
                                      )
                                    : Border.all(
                                        color: Color(0xffa6d1c4),
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: (_myEvents.containsKey(
                                              DateTime.utc(day.year, day.month,
                                                  day.day)))
                                          ? Colors.black38
                                          : Colors.black87,
                                    ),
                                  ),
                                  _buildEventMaker(ref, day),
                                ],
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: (_editmode)
                                  ? EdgeInsets.all(3.0)
                                  : EdgeInsets.all(1.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: (_editmode)
                                    ? (_myEvents.containsKey(DateTime.utc(
                                            day.year, day.month, day.day)))
                                        ? Border.all(
                                            color: Colors.black26,
                                            width: 0.8,
                                            style: BorderStyle.solid,
                                          )
                                        : Border.all(
                                            color: Color(0xffa6d1c4),
                                            width: 1.5,
                                            style: BorderStyle.solid,
                                          )
                                    : (_myEvents.containsKey(DateTime.utc(
                                            day.year, day.month, day.day)))
                                        ? Border.all(
                                            color: Colors.black45,
                                            width: 2.5,
                                            style: BorderStyle.solid,
                                          )
                                        : Border.all(
                                            color: Color(0xffa6d1c4),
                                            width: 3.0,
                                            style: BorderStyle.solid,
                                          ),
                                color: (_editmode)
                                    ? Colors.white
                                    : Color(0xfffcdc12),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: (_myEvents.containsKey(
                                              DateTime.utc(day.year, day.month,
                                                  day.day)))
                                          ? Colors.black87
                                          : Colors.black87,
                                    ),
                                  ),
                                  _buildEventMaker(ref, day),
                                ],
                              ),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(3.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: (_myEvents.containsKey(DateTime.utc(
                                        day.year, day.month, day.day)))
                                    ? Border.all(
                                        color: Colors.black26,
                                        width: 0.8,
                                        style: BorderStyle.solid,
                                      )
                                    : Border.all(
                                        color: Color(0xffa6d1c4),
                                        width: 1.5,
                                        style: BorderStyle.solid,
                                      ),
                                color: Color(0xfffcdc12).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: (_myEvents.containsKey(
                                              DateTime.utc(day.year, day.month,
                                                  day.day)))
                                          ? Colors.black38
                                          : Colors.black87,
                                    ),
                                  ),
                                  _buildEventMaker(ref, day),
                                ],
                              ),
                            );
                          },
                          outsideBuilder: (context, day, focusedDay) {
                            return Container(
                              margin: EdgeInsets.all(3.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          dowBuilder: (_, day) {
                            if (day.weekday == DateTime.sunday) {
                              return const Center(
                                child: Text(
                                  "日",
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (day.weekday == DateTime.saturday) {
                              return const Center(
                                child: Text(
                                  "土",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      Offstage(
                        offstage: ((areaHeight * 0.06) - _deltaPosition) < 0,
                        child: Opacity(
                          opacity: (((areaHeight * 0.06) - _deltaPosition) /
                                  (areaHeight * 0.06))
                              .clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              // Container(height: areaHeight * 0.05, color: Colors.blue),
                              SizedBox(height: areaHeight * 0.05),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Users state",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: areaHeight * 0.1,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _friendsInformation.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: areaHeight * 0.005,
                                        right: areaHeight * 0.005,
                                      ),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          (_friendsEvents[
                                                      _friendsInformation[index]
                                                          .id]!
                                                  .containsKey(DateTime.utc(
                                                      _focusedDay.year,
                                                      _focusedDay.month,
                                                      _focusedDay.day)))
                                              ? Colors.white.withOpacity(0.6)
                                              : Colors.white.withOpacity(0.0),
                                          BlendMode.srcATop,
                                        ),
                                        child: CircleAvatar(
                                          radius: areaHeight * 0.03,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                            '${_friendsInformation[index].imageUrl}',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
