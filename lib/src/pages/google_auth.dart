import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserController{
  static bool isSignedInWithGoogle = false;

  static User? user;
  static String? userId;

  static void setUser(User? newUser) {
    user = newUser;
  }
  static ValueNotifier<User?> userNotifier = ValueNotifier<User?>(null);



  static Future<User?> loginWithGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();

    final googleAuth = await googleAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );
    isSignedInWithGoogle = true;
    userId = userCredential.user?.uid;
    return userCredential.user;
  }
  static void initListeners() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      userNotifier.value = user;
    });
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }


}

class FirebaseAuthService{
  static String? userId;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailAndPasssword(String email, String password, context) async {
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Este correo electrónico ya está registrado.'),
        ),
      );
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password, context) async{
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      userId = credential.user?.uid;
      return credential.user;
    } on FirebaseAuthException catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('El correo electrónico no está registrado.'),
        ),
      );
    }
  }
}