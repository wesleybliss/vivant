import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vivant/utils/logger.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;

  static const String _idTokenKey = 'firebase_id_token';
  static const String _userIdKey = 'firebase_user_id';

  AuthService() {
    _initGoogleSignIn();
  }

  void _initGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // Let it auto-detect from google-services.json
    );
  }

  // Sign in with Google using Firebase Auth
  Future<bool> signInWithGoogle() async {
    try {
      Logger.info('Starting Google Sign-In...');

      // Step 1: Sign in with Google (native flow)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Logger.warning('Google sign-in cancelled');
        return false;
      }

      // Step 2: Get Google auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        Logger.error('Failed to get Google auth tokens');
        return false;
      }

      Logger.info('Google sign-in successful!');

      // Step 3: Sign in to Firebase with Google credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        Logger.error('Failed to get Firebase user');
        return false;
      }

      // Step 4: Get Firebase ID token for backend authentication
      final String? firebaseIdToken = await user.getIdToken();

      if (firebaseIdToken == null) {
        Logger.error('Failed to get Firebase ID token');
        return false;
      }

      // Store tokens securely
      await _secureStorage.write(key: _idTokenKey, value: firebaseIdToken);
      await _secureStorage.write(key: _userIdKey, value: user.uid);

      Logger.info('Firebase sign-in successful! User ID: ${user.uid}');
      return true;
    } catch (e, stackTrace) {
      Logger.error('Sign in error: $e', e, stackTrace);
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    // Check if we have a stored token
    final token = await _secureStorage.read(key: _idTokenKey);
    if (token == null || token.isEmpty) {
      return false;
    }

    // Check if Firebase user is still signed in
    final user = _firebaseAuth.currentUser;
    return user != null;
  }

  // Get the current Firebase ID token (for backend authentication)
  Future<String?> getAccessToken() async {
    try {
      // Try to get fresh token from Firebase Auth
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true); // force refresh
        if (token != null) {
          // Update stored token
          await _secureStorage.write(key: _idTokenKey, value: token);
          return token;
        }
      }

      // Fallback to stored token if Firebase user is null
      return await _secureStorage.read(key: _idTokenKey);
    } catch (e) {
      Logger.error('Error getting access token: $e');
      // Return stored token as fallback
      return await _secureStorage.read(key: _idTokenKey);
    }
  }

  // Get the current user ID
  Future<String?> getUserId() async {
    final user = _firebaseAuth.currentUser;
    return user?.uid ?? await _secureStorage.read(key: _userIdKey);
  }

  // Convenience method that calls signInWithGoogle
  Future<bool> signIn() async {
    return await signInWithGoogle();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      Logger.info('Signing out...');

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear stored tokens
      await _secureStorage.delete(key: _idTokenKey);
      await _secureStorage.delete(key: _userIdKey);

      Logger.info('Signed out successfully');
    } catch (e) {
      Logger.error('Sign out error: $e');
    }
  }

  // Refresh Firebase ID token
  Future<bool> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true); // force refresh
        if (token != null) {
          await _secureStorage.write(key: _idTokenKey, value: token);
          Logger.info('Token refreshed successfully');
          return true;
        }
      }
      Logger.warning('No user found to refresh token');
      return false;
    } catch (e) {
      Logger.error('Token refresh error: $e');
      return false;
    }
  }
}
