import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of auth state changes. Emits a User when logged in, null when logged out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Signs up a new user with email/password.
  /// Throws a FirebaseAuthException on failure (handled by the caller for UI display).
  Future<User?> signUp({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Signs in an existing user with email/password.
  Future<User?> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Converts Firebase error codes into friendly, readable messages.
  String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}