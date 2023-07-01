import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {super.key,
      required this.user,
      required this.email,
      required this.password});

  final User user;
  final String email;
  final String password;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;
  String? name;

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future signUp() async {
    final storageRef = FirebaseStorage.instance.ref();
    final path = 'users/${widget.user.uid}/${image!.path.split('/').last}';
    final firestore = FirebaseFirestore.instance;

    try {
      await image!.readAsBytes().then(
            (data) async => await storageRef.child(path).putData(data).then(
                  (taskSnapshot) async =>
                      await taskSnapshot.ref.getDownloadURL().then((imageUrl) {
                    final List<String> friendList = [];
                    firestore.collection('users').doc(widget.user.uid).set({
                      'id': widget.user.uid,
                      'name': name,
                      'imageUrl': imageUrl,
                      'friendLidt': friendList,
                    }).whenComplete(
                      () async => await firestore
                          .collection('events')
                          .doc(widget.user.uid)
                          .set({}).whenComplete(
                        () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
          );
    } catch (e) {
      print('Failed to upload: $e');
      await widget.user.delete();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyApp(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: main,
      body: SafeArea(
        child: Container(
          color: main,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_circle),
                    labelText: 'ユーザーネーム',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      name = value;
                    });
                  },
                ),
                SizedBox(height: 40),
                Text("プロフィール写真を選択"),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: (image != null)
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(image!),
                        )
                      : Icon(
                          Icons.add_circle,
                          color: Colors.grey,
                          size: 120,
                        ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    signUp();
                  },
                  child: const Text('サインアップ'),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 30.0),
                //   child: Divider(
                //     height: 3,
                //     color: Colors.black54,
                //   ),
                // ),
                // const Text('SNSでログイン'),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.),
                //     ),
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.facebook),
                //     ),
                //     IconButton(
                //       onPressed: () {},
                //       icon: const Icon(Icons.apple),
                //     ),
                //   ],
                // ),
                SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
