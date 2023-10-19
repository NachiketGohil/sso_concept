import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sso_concept/bloc.dart';
import 'package:sso_concept/constants.dart';

class UserData extends StatefulWidget {
  final GoogleSignInAccount? user;
  final AuthorizationCredentialAppleID? appleCredential;
  final bool loginMethod;

  const UserData({
    super.key,
    this.user,
    this.appleCredential,
    required this.loginMethod,
  });

  @override
  State<UserData> createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  final Bloc bloc = Bloc();
  GoogleSignInAuthentication? auth;

  Future setupSsoData() async {
    if (widget.loginMethod) {
      /// Apple Account
      Constants.userPhoto = '';
      Constants.userName =
          "${widget.appleCredential?.givenName}  ${widget.appleCredential?.familyName}";
      Constants.userEmail = "${widget.appleCredential?.email}";
      Constants.userId = "${widget.appleCredential?.identityToken}";
      Constants.appleAuthCode = "${widget.appleCredential?.authorizationCode}";
    } else {
      /// Google Account
      auth = await widget.user!.authentication;
      Constants.userPhoto = widget.user?.photoUrl ?? Constants.brokenImage;
      Constants.userName = widget.user?.displayName ?? "Not Found";
      Constants.userEmail = widget.user?.email ?? "Not Found";
      Constants.userId = auth?.idToken ?? "Not Found";
      Constants.googleAccessToken = auth?.accessToken ?? "Not Found";
    }
    setState(() {});
  }

  @override
  void initState() {
    setupSsoData();
    super.initState();
  }

  @override
  void dispose() {
    Constants.userPhoto = '';
    Constants.userName = '';
    Constants.userEmail = '';
    Constants.userId = '';
    Constants.userIdToken = '';
    Constants.error = '';
    super.dispose();
  }

  checkUserStatus() {
    if (widget.loginMethod) {
      /// Apple User
    } else {
      /// Google User
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("User Data"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              widget.loginMethod ? Icons.apple_rounded : Icons.android_rounded,
              size: 50,
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!widget.loginMethod)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                        Uri.parse(Constants.userPhoto).toString(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    Constants.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    Constants.userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.loginMethod)
                    Text(
                      "Apple Auth Code:::> \n${Constants.appleAuthCode}",
                      style: const TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  if (!widget.loginMethod)
                    Text(
                      "Google Access token:::> \n${Constants.googleAccessToken}",
                      style: const TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  const Text("ID TOKEN:::>"),
                  Text(
                    Constants.userId,
                    style: const TextStyle(
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 30, right: 40, left: 40),
        child: (!widget.loginMethod)
            ? ElevatedButton(
                onPressed: () async {
                  await bloc.logoutGoogle();
                  Navigator.of(context).pop();
                },
                child: const Text("Logout"),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
