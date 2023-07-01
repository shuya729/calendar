import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../providers/add_friend_privder.dart';
import '../providers/userdata_providers.dart';

class AddFriendScreen extends ConsumerWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const Color stroke = Color(0xff00214d);
    const Color main = Color(0xfffffffe);
    const Color highLight = Color(0xff00ebc7);
    const Color secondary = Color(0xffff5470);
    const Color tertiary = Color(0xfffde24f);
    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final double areaWidth = MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.left -
        MediaQuery.of(context).padding.right;
    final List<UserData> serchedUsers = ref.watch(serchedUsersProvider);
    final UserData myInformation =
        ref.watch(myInformationProvider).asData!.value;

    return Scaffold(
      backgroundColor: main,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: areaHeight * 0.005,
            horizontal: areaWidth * 0.05,
          ),
          color: main,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: stroke,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Text(
                    '友達を追加',
                    style: TextStyle(
                      color: stroke,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 50),
                ],
              ),
              TextFormField(
                style: TextStyle(
                  color: stroke,
                ),
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'ユーザーID または ユーザーネーム',
                  labelStyle: TextStyle(
                    color: stroke,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stroke,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: stroke,
                    ),
                  ),
                  iconColor: stroke,
                ),
                onChanged: (String field) {
                  ref
                      .read(serchedUsersProvider.notifier)
                      .makeSerchedUsers(field);
                },
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: serchedUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          serchedUsers[index].imageUrl,
                        ),
                      ),
                      title: Text(
                        serchedUsers[index].name,
                        style: TextStyle(
                          color: stroke,
                          fontSize: 20,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(myInformation.id)
                              .update({
                            'friendList':
                                FieldValue.arrayUnion([serchedUsers[index].id]),
                          });
                        },
                        icon: Icon(
                          Icons.person_add,
                          color: stroke,
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
    );
  }
}
