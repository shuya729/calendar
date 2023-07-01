import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../models/user_model.dart';

class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key, required this.myInformation});

  final UserData myInformation;

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  late String name;
  late File? image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = widget.myInformation.name;
    final iamgeUrl = widget.myInformation.imageUrl;
    image = null;
  }

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

  Future reNew() async {
    final storageRef = FirebaseStorage.instance.ref();
    final firestore = FirebaseFirestore.instance;

    try {
      if (image != null) {
        final path =
            'users/${widget.myInformation.id}/${image!.path.split('/').last}';
        await image!.readAsBytes().then(
              (data) async => await storageRef.child(path).putData(data).then(
                    (taskSnapshot) async => await taskSnapshot.ref
                        .getDownloadURL()
                        .then((imageUrl) {
                      firestore
                          .collection('users')
                          .doc(widget.myInformation.id)
                          .update({
                        'name': name,
                        'imageUrl': imageUrl,
                      }).whenComplete(
                        () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ),
                        ),
                      );
                    }),
                  ),
            );
      } else {
        firestore.collection('users').doc(widget.myInformation.id).update({
          'name': name,
        }).whenComplete(
          () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MyApp(),
            ),
          ),
        );
      }
    } catch (e) {
      print('Failed to upload: $e');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MyApp(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color main = Color(0xfffffffe);
    const Color highLight = Color(0xff00ebc7);
    const Color secondary = Color(0xffff5470);
    final double areaHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final String preName = widget.myInformation.name;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: secondary,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: areaHeight * 0.92,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: ShapeDecoration(
                  color: main,
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
                        'プロフィール編集',
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
                        initialValue: name,
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
                            : CircleAvatar(
                                radius: 60,
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.myInformation.imageUrl,
                                ),
                              ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          reNew();
                        },
                        child: const Text('更新'),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const MyApp(),
                            ),
                          );
                        },
                        child: const Text('キャンセル'),
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
