import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool hidePassword = true;
  final _formKey = GlobalKey<FormState>();

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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Signup',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 40),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            labelText: 'メールアドレス',
                          ),
                          onChanged: (String value) {
                            setState(() {
                              email = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'メールアドレスを入力してください';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            labelText: 'パスワード',
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを入力してください';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          obscureText: hidePassword,
                          decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            labelText: 'パスワード(確認用)',
                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),
                          ),
                          onChanged: (String value) {
                            setState(() {
                              confirmPassword = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'パスワードを再入力してください';
                            }
                            if (value != password) {
                              return 'パスワードが一致しません';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                await FirebaseAuth.instance
                                    .createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                )
                                    .whenComplete(() {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          user: user,
                                          email: email,
                                          password: password,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'weak-password') {
                                  print('The password provided is too weak.');
                                } else if (e.code == 'email-already-in-use') {
                                  print(
                                      'The account already exists for that email.');
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                          },
                          child: const Text('次へ'),
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
            ),
          ],
        ),
      ),
    );
  }
}
