import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Current user getters ──────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  String get displayName =>
      (currentUser?.userMetadata?['display_name'] as String?) ?? '';

  String get email => currentUser?.email ?? '';

  String? get photoUrl =>
      currentUser?.userMetadata?['avatar_url'] as String?;

  /// Stream that emits whenever the auth state changes (sign-in, sign-out,
  /// token refresh, etc.).  Listen in your controller to keep the UI in sync.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Sign-up ───────────────────────────────────────────────────────────────

  /// Creates a new account.
  ///
  /// Throws [AuthException] on failure (e.g. email already registered).
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );
  }

  // ── Sign-in ───────────────────────────────────────────────────────────────

  /// Signs in with email and password.
  ///
  /// Throws [AuthException] on failure (e.g. wrong credentials).
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Sign-out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('AuthService.signOut error: $e');
    }
  }

  // ── Profile update ────────────────────────────────────────────────────────

  /// Updates the display name stored in the user's metadata.
  Future<void> updateDisplayName(String name) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'display_name': name}),
    );
  }

  // ── Password reset ────────────────────────────────────────────────────────

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}

