import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/models.dart';
import 'session_store.dart';
export 'session_store.dart';

class SessionController extends ChangeNotifier {
  SessionController({SessionStore? store, DateTime Function()? now})
    : _store = store ?? createSessionStore(),
      _now = now ?? DateTime.now {
    try {
      final raw = _store.read();
      if (raw != null) {
        final value = LoginResult.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        if (value.token.isNotEmpty &&
            value.user.id > 0 &&
            DateTime.parse(value.expiresAt).isAfter(_now())) {
          _session = value;
          _scheduleExpiry();
        } else {
          _store.write(null);
        }
      }
    } catch (_) {
      _store.write(null);
    }
  }
  final SessionStore _store;
  final DateTime Function() _now;
  LoginResult? _session;
  int _generation = 0;
  Timer? _expiryTimer;
  LoginResult? get session => _session;
  UserProfile? get user => _session?.user;
  String get token => _session?.token ?? '';
  int get generation => _generation;
  bool get signedIn => _session != null;
  void setSession(LoginResult value) {
    _generation++;
    _session = value;
    _scheduleExpiry();
    _persist();
    notifyListeners();
  }

  void updateProfile(UserProfile user) {
    if (_session == null) return;
    _session = _session!.copyWith(user: user);
    _persist();
    notifyListeners();
  }

  void clear() {
    _generation++;
    _session = null;
    _expiryTimer?.cancel();
    _persist();
    notifyListeners();
  }

  void _persist() =>
      _store.write(_session == null ? null : jsonEncode(_session!.toJson()));
  void _scheduleExpiry() {
    _expiryTimer?.cancel();
    final value = _session;
    if (value == null) return;
    final remaining = DateTime.parse(value.expiresAt).difference(_now());
    final generation = _generation;
    final delay = remaining > const Duration(days: 1)
        ? const Duration(days: 1)
        : remaining;
    _expiryTimer = Timer(delay, () {
      if (generation != _generation) return;
      if (DateTime.parse(value.expiresAt).isAfter(_now())) {
        _scheduleExpiry();
      } else {
        clear();
      }
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}
