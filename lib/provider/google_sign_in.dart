import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test0/screen/myview/mydialog.dart';

class GoogleSignInProvider extends ChangeNotifier {
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          MyDialog.showSnackBar(
            context: context,
            message: 'Sign In Error: $e',
            seconds: 30,
          );
        } else if (e.code == 'invalid-credential') {
          MyDialog.showSnackBar(
            context: context,
            message: '$e',
            seconds: 30,
          );
        }
      } catch (e) {
        MyDialog.showSnackBar(
          context: context,
          message: 'Error: $e',
          seconds: 30,
        );
      }
    }
    return user;
  }

  //@override
  notifyListeners();
}
