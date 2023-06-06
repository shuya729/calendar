import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? image;
  String? name;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future signUp() async {
    final storageRef = FirebaseStorage.instance.ref();
    final uploadRef = storageRef
        .child('users/${widget.user.uid}/${image!.path.split('/').last}');
    final firestore = FirebaseFirestore.instance;

    try {
      await uploadRef.putFile(image!).then((taskSnapshot) async {
        await taskSnapshot.ref.getDownloadURL().then((imageUrl) {
          firestore.collection('users').doc(widget.user.uid).set({
            'id': widget.user.uid,
            'name': name,
            'imageUrl': imageUrl,
            'freindLidt': [],
            'eventMap': {},
          }).then((value) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MainScreen()));
          });
        });
      });
    } catch (e) {
      print('Failed to upload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Color(0xffa6d1c4),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: areaHeight * 0.85,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(areaHeight * 0.05),
                      topLeft: Radius.circular(areaHeight * 0.05),
                    ),
                  ),
                ),
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
                      SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
