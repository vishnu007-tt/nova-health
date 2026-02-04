import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../pages/auth/mfa_challenge_page.dart';

/// -------------------- AUTH STATE --------------------

class AuthState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final UserModel? user;

  const AuthState({
    required this.isLoading,
    this.error,
    this.successMessage,
    this.user,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      error: null,
      successMessage: null,
      user: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    UserModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      user: user ?? this.user,
    );
  }
}

/// -------------------- AUTH PROVIDER --------------------

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState.initial());

/// SIGN UP
Future<void> signUp({
  required String email,
  required String password,
  required String username,
}) async {
  print("AuthNotifier.signUp called");

  state = state.copyWith(
    isLoading: true,
    error: null,
    successMessage: null,
  );

  try {
    print("Calling AuthService.signUp...");

    final result = await _authService.signUp(
      email: email,
      password: password,
      username: username,
    );

    print("AuthService.signUp returned: success=${result.success}");

    if (result.success) {
      print("SIGN UP SUCCESS - updating state");
      state = state.copyWith(
        isLoading: false,
        user: result.user,
        successMessage: result.message,
        error: null,
      );
    } else {
      print("SIGN UP FAILED: ${result.message}");
      state = state.copyWith(
        isLoading: false,
        error: result.message,
        successMessage: null,
      );
    }
  } catch (e) {
    print("AuthNotifier.signUp exception: $e");
    state = state.copyWith(
      isLoading: false,
      error: 'Something went wrong. Please try again.',
      successMessage: null,
    );
  }
}


  /// LOGIN
  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    );

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          user: result.user,
          successMessage: result.message,
          error: null,
        );
        
        // IMPORTANT: Refresh currentUserProvider to update with new user
        // This ensures the app shows the correct user after login
        final container = ProviderScope.containerOf(context);
        container.read(currentUserProvider.notifier).refresh();
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
          successMessage: null,
        );
      }
    } on FirebaseAuthMultiFactorException catch (e) {
      // IMPORTANT:
      // We intentionally navigate here instead of setting user state.
      // User must complete MFA challenge before being considered authenticated.
      // MFA required: navigate to challenge page so user can verify second factor.
      state = state.copyWith(isLoading: false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MfaChallengePage(exception: e),
        ),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
        successMessage: null,
      );
    }
  }

  /// LOGOUT
  Future<void> logout(WidgetRef ref) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      successMessage: null,
    );
    try {
      await _authService.logout();
      state = AuthState.initial();
      
      // IMPORTANT: Clear currentUserProvider to ensure clean state
      ref.read(currentUserProvider.notifier).setUser(null);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to log out',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

/// -------------------- CURRENT USER PROVIDER --------------------

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService = AuthService();
  final DatabaseService _db = DatabaseService();

  CurrentUserNotifier() : super(null) {
    // load current user when first read
    final user = _authService.getCurrentUser();
    state = user;
  }

  /// Explicitly set user (e.g. after editing profile or gender)
  void setUser(UserModel? user) {
    state = user;
  }

  /// Refresh from AuthService / local DB
  void refresh() {
    state = _authService.getCurrentUser();
  }

  /// Update and save user details locally (and later Firestore if you want)
  Future<void> updateUser(UserModel updatedUser) async {
    await _db.saveUser(updatedUser);
    state = updatedUser;
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>(
  (ref) => CurrentUserNotifier(),
);

/// -------------------- IS LOGGED IN PROVIDER --------------------

/// Simple bool flag for things like MyApp routing
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.user != null;
});
