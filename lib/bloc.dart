import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sso_concept/constants.dart';

class Bloc {
  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: ['profile', 'email'],
  );

  Future<GoogleSignInAccount?> loginGoogle() async {
    try {
      if (Platform.isIOS) {
        googleSignIn = GoogleSignIn(
          clientId: Constants.iosClientID,
        );
      }
      return await googleSignIn.signIn();
    } catch (e) {
      Constants.error = e.toString();
      print("Google ERRORR \n${Constants.error}");
      return null;
    }
  }

  Future logoutGoogle() async {
    if (Platform.isIOS) {
      googleSignIn = GoogleSignIn(
        clientId: Constants.iosClientID,
      );
    }
    print("Current user is Signed IN ${await googleSignIn.isSignedIn()}");
    await googleSignIn.disconnect();
    print("Current user is Disconnected: SIgn in ${await googleSignIn.isSignedIn()}");
    await googleSignIn.signOut();
    print("Current user is Signed IN ${await googleSignIn.isSignedIn()}");
  }

  Future logoutGoogleFallback() async {
    if (Platform.isIOS) {
      googleSignIn = GoogleSignIn(
        clientId: Constants.iosClientID,
      );
    }
    await googleSignIn.signOut();
  }

  Future<AuthorizationCredentialAppleID?> loginApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      return appleCredential;
    } catch (exception) {
      Constants.error = exception.toString();
      print("APPPLLLEEE Exception");
      print(Constants.error);
      return null;
    }
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
