import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/models.dart';
import 'api_client.dart';
import 'session_controller.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this.api, required this.session}) {
    api.onAuthError = _authError;
    session.addListener(_sessionChanged);
  }
  final ApiClient api;
  final SessionController session;
  bool checking = false;
  bool busy = false;
  bool validated = false;
  String? error;
  int _operation = 0;
  bool _disposed = false;
  UserProfile? get user => session.user;
  bool get signedIn => session.signedIn;
  bool get isAdmin => user?.role == 'ADMIN';

  void _sessionChanged() {
    if (!session.signedIn) validated = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> initialize() => validateProfile();
  Future<void> validateProfile() async {
    if (!session.signedIn || checking) return;
    final generation = session.generation;
    checking = true;
    error = null;
    _notify();
    try {
      final json = await api.request(
        'GET',
        '/user/profile',
        handleAuthError: false,
      );
      if (generation != session.generation) return;
      final profile = UserProfile.fromJson(
        Map<String, dynamic>.from(json as Map),
      );
      if (profile.status != 'ACTIVE') {
        session.clear();
        error = '账号已停用，请联系管理员';
      } else {
        session.updateProfile(profile);
        validated = true;
      }
    } on ApiException catch (exception) {
      if (generation != session.generation) return;
      if (exception.code == 401) session.clear();
      // A network error is not evidence that a stored session is invalid.
      error = exception.message;
      validated = false;
    } on StaleSessionException {
      return;
    } catch (_) {
      if (generation == session.generation) {
        error = '无法验证账号信息，请重试';
        validated = false;
      }
    } finally {
      checking = false;
      _notify();
    }
  }

  Future<void> _authError(int code, int generation) async {
    if (generation != session.generation) return;
    if (code == 401) {
      session.clear();
      error = '登录已过期，请重新登录';
      _notify();
      return;
    }
    // 403 may mean a forced password change or a changed role; re-read profile.
    await validateProfile();
  }

  Future<bool> login(String username, String password) async {
    final operation = ++_operation;
    session.clear();
    busy = true;
    error = null;
    _notify();
    try {
      final json = await api.request(
        'POST',
        '/user/login',
        authenticated: false,
        data: {'username': username.trim(), 'password': password},
      );
      if (operation != _operation) return false;
      session.setSession(
        LoginResult.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      validated = true;
      return true;
    } on StaleSessionException {
      return false;
    } catch (exception) {
      if (operation == _operation) {
        error = exception is ApiException ? exception.message : '登录响应异常';
      }
      return false;
    } finally {
      if (operation == _operation) {
        busy = false;
        _notify();
      }
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final operation = ++_operation;
    final generation = session.generation;
    busy = true;
    error = null;
    _notify();
    try {
      await api.request(
        'PUT',
        '/user/password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      if (generation != session.generation) return false;
      session.clear();
      error = '密码已修改，请重新登录';
      return true;
    } on StaleSessionException {
      return false;
    } catch (exception) {
      if (generation == session.generation) {
        error = exception is ApiException ? exception.message : '修改密码失败';
      }
      return false;
    } finally {
      if (operation == _operation) {
        busy = false;
        _notify();
      }
    }
  }

  Future<void> logout() async {
    ++_operation;
    final token = session.token;
    session.clear();
    error = null;
    busy = false;
    _notify();
    if (token.isEmpty) return;
    try {
      await api.request(
        'POST',
        '/user/logout',
        capturedToken: token,
        isolate: false,
        handleAuthError: false,
      );
    } catch (_) {
      /* Local logout is immediate even when revocation cannot reach the server. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    session.removeListener(_sessionChanged);
    api.onAuthError = null;
    super.dispose();
  }
}
