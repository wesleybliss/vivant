import 'package:flutter/foundation.dart';
import 'package:vivant/services/auth_service.dart';
import 'package:vivant/services/convex_service.dart';
import 'package:vivant/utils/logger.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final AuthService authService;
  final ConvexService convexService;

  AuthState _state = AuthState.initial;
  String? _error;
  String? _userId;

  AuthProvider({
    required this.authService,
    required this.convexService,
  });

  AuthState get state => _state;
  String? get error => _error;
  String? get userId => _userId;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _setState(AuthState.loading);

    try {
      final isAuth = await authService.isAuthenticated();
      if (isAuth) {
        final token = await authService.getAccessToken();
        final userId = await authService.getUserId();

        if (token != null) {
          convexService.setAuthToken(token);
          _userId = userId;
          _setState(AuthState.authenticated);
          Logger.info('User is authenticated');
        } else {
          _setState(AuthState.unauthenticated);
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      Logger.error('Error checking auth status: $e');
      _setError('Failed to check authentication status');
    }
  }

  // Sign in
  Future<bool> signIn() async {
    _setState(AuthState.loading);

    try {
      final success = await authService.signIn();
      if (success) {
        final token = await authService.getAccessToken();
        final userId = await authService.getUserId();

        if (token != null) {
          convexService.setAuthToken(token);
          _userId = userId;

          // Ensure default lists exist for new users
          try {
            await convexService.ensureDefaultLists();
          } catch (e) {
            Logger.warning('Failed to ensure default lists: $e');
          }

          _setState(AuthState.authenticated);
          Logger.info('Sign in successful');
          return true;
        }
      }

      _setError('Sign in failed');
      return false;
    } catch (e) {
      Logger.error('Sign in error: $e');
      _setError('Sign in failed: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await authService.signOut();
      convexService.setAuthToken(null);
      _userId = null;
      _setState(AuthState.unauthenticated);
      Logger.info('Sign out successful');
    } catch (e) {
      Logger.error('Sign out error: $e');
      _setError('Sign out failed');
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final success = await authService.refreshToken();
      if (success) {
        final token = await authService.getAccessToken();
        if (token != null) {
          convexService.setAuthToken(token);
          Logger.info('Token refreshed');
          return true;
        }
      }
      return false;
    } catch (e) {
      Logger.error('Token refresh error: $e');
      return false;
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = AuthState.error;
    notifyListeners();
  }
}
