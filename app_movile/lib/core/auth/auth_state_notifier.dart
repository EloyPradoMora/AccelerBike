import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthStateNotifier extends ChangeNotifier {
  User? _currentUser = Supabase.instance.client.auth.currentUser;
  StreamSubscription<AuthState>? _sub;

  AuthStateNotifier._internal() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  static final AuthStateNotifier instance = AuthStateNotifier._internal();

  bool    get isAuthenticated => _currentUser != null;
  String? get userId          => _currentUser?.id;
  bool    get isAnonymous     => _currentUser?.isAnonymous ?? true;
  String  get displayEmail    =>
      (_currentUser?.isAnonymous ?? true) ? 'Demo AccelerBike' : (_currentUser?.email ?? '');

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}