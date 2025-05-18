import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  final StreamController<Session?> authStateController = StreamController.broadcast();

  @override
  Stream<Session?> build() {
    final streamSub = client.auth.onAuthStateChange.listen((authState) {
      final session = authState.session;
      authStateController.add(session);
    });

    ref.onDispose(() {
      streamSub.cancel();
      authStateController.close();
    });
    return authStateController.stream;
  }

  SupabaseClient get client => Supabase.instance.client;
  Session? get currentSession => client.auth.currentSession;

  Future<void> signInWithPassword(String email, String password) async {
    try {
      await client.auth.signInWithPassword(password: password, email: email);
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    try {
      await client.auth.signUp(password: password, email: email, data: data);
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      final redirectUrl = kIsWeb ? '${Uri.base.origin}/reset' : null;
      await client.auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
    } catch (e) {
      debugPrint('Error recovering password: $e');
      rethrow;
    }
  }
} 