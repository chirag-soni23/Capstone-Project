import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId:
      '768830069207-0ss2i8nvhan88ukg8ge3up51d1ddh1qa.apps.googleusercontent.com',
    );

    final GoogleSignInAccount googleUser =
    await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final String? googleIdToken = googleAuth.idToken;

    if (googleIdToken == null) {
      throw Exception('Google ID token not found');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleIdToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);

    final User? firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception('Firebase user not found');
    }

    final String? firebaseIdToken =
    await firebaseUser.getIdToken();

    if (firebaseIdToken == null) {
      throw Exception('Firebase ID token not found');
    }

    return firebaseIdToken;
  }

  static Future<void> logout() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}