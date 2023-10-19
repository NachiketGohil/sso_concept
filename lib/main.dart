import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sso_concept/bloc.dart';
import 'package:sso_concept/constants.dart';
import 'package:sso_concept/user_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSO Concept',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Bloc bloc = Bloc();
  String status = '';
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['profile', 'email'],
  );

  @override
  void initState() {
    Constants.userPhoto = '';
    Constants.userName = '';
    Constants.userEmail = '';
    Constants.userId = '';
    Constants.userIdToken = '';
    Constants.error = '';

    super.initState();
  }

  Future checkCurrentUserStatus() async {
    status = "Current User : ${googleSignIn.currentUser?.email} \n"
        " is Signed In ${await googleSignIn.isSignedIn()}";
  }

  @override
  Widget build(BuildContext context) {
    checkCurrentUserStatus();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Authentication"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(status),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final user = await bloc.loginGoogle();
                    if (user != null) {
                      print("GOOOOGLE USER NOT NULL");
                      print("GOOOOGLE PHOTO URL::::${user.photoUrl}");
                      print("GOOOOGLE NAME::::${user.displayName!}");
                      print("GOOOOGLE EMAIL::::${user.email}");
                      print("GOOOOGLE USER ID::::${user.id}");
                      final auth = await user.authentication;
                      print("Auth DONE");

                      print("GOOOOGLE ID TOKEN::::${auth.idToken ?? "NULL ID TOKEN"}");
                      print("GOOOOGLE Access TOken::::${auth.accessToken ?? "NULL ID TOKEN"}");

                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => UserData(
                          user: user,
                          loginMethod: false,
                        ),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Google ERROR ${Constants.error}"),
                          showCloseIcon: true,
                          duration: const Duration(seconds: 10),
                        ),
                      );
                    }
                  },
                  child: const Text("Sign-in with Google"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await bloc.logoutGoogleFallback();
                  },
                  child: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (Platform.isIOS)
              ElevatedButton(
                onPressed: () async {
                  final appleCredential = await bloc.loginApple();
                  if (appleCredential != null) {
                    if (appleCredential.identityToken != null) {
                      print("APPPLLLEEE IDDD TOKEN::::${appleCredential.identityToken!}");
                      print("APPPLLLEEE State::::${appleCredential.state ?? "unknown"}");
                      print("APPPLLLEEE Given Name::::${appleCredential.givenName ?? "unknown"}");
                      print("APPPLLLEEE Family Name::::${appleCredential.familyName ?? "unknown"}");
                      print("APPPLLLEEE Email::::${appleCredential.email ?? "unknown"}");
                      print("APPPLLLEEE Auth Code::::${appleCredential.authorizationCode}");
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => UserData(
                          appleCredential: appleCredential,
                          loginMethod: true,
                        ),
                      ));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Apple ERROR ${Constants.error}"),
                        showCloseIcon: true,
                        duration: const Duration(seconds: 10),
                      ),
                    );
                  }
                },
                child: const Text("Sign-in with Apple"),
              ),
          ],
        ),
      ),
    );
  }
}
