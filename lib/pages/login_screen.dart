import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../pages/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool hidePassword = true;

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Spacer(flex: 8),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(flex: 3),
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
                ),
                TextFormField(
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock),
                    labelText: 'パスワード',
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
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
                ),
                Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      )
                          .whenComplete(() {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MyApp(),
                          ),
                        );
                      });
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        print('No user found for that email.');
                      } else if (e.code == 'wrong-password') {
                        print('Wrong password provided for that user.');
                      }
                    }
                  },
                  child: const Text('ログイン'),
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
                Spacer(flex: 2),
                Divider(
                  height: 3,
                  color: Colors.black54,
                ),
                Spacer(flex: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('アカウントをお持ちでない方は'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('こちら'),
                    ),
                  ],
                ),
                Spacer(flex: 10),
              ],
            ),
          ),
        ),
        // Stack(
        //   fit: StackFit.expand,
        //   children: [
        //     Container(
        //       color: secondary,
        //     ),
        //     Align(
        //       alignment: Alignment.bottomCenter,
        //       child: Container(
        //         height: areaHeight * 0.92,

        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
