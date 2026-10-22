import 'dart:async';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../../data/repositories/moneyday_repository.dart';
import '../../data/services/api_client.dart';

abstract class FeatureViewModel extends ChangeNotifier {
  FeatureViewModel(this.repository) {
    repository.addListener(_repositoryChanged);
  }
  final MoneydayRepository repository;
  bool loading = false;
  bool saving = false;
  String? error;
  bool _disposed = false;
  bool _reload = false;
  int _loadId = 0;
  Future<void> fetch();
  void _repositoryChanged() {
    unawaited(load());
  }

  Future<void> load() async {
    if (_disposed) return;
    if (loading) {
      _reload = true;
      return;
    }
    final generation = repository.sessionGeneration;
    final requestId = ++_loadId;
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (repository.authenticated) {
        await ApiClient.inSession(generation, fetch);
      }
    } on StaleSessionException {
      /* The new route owns the new session's state. */
    } catch (exception) {
      if (!_disposed &&
          generation == repository.sessionGeneration &&
          requestId == _loadId) {
        error = exception is ApiException ? exception.message : '数据加载失败，请刷新重试';
      }
    } finally {
      if (!_disposed && requestId == _loadId) {
        loading = false;
        notifyListeners();
        if (_reload) {
          _reload = false;
          unawaited(load());
        }
      }
    }
  }

  Future<bool> run(Future<void> Function() command) async {
    if (saving || _disposed || !repository.authenticated) return false;
    final generation = repository.sessionGeneration;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await ApiClient.inSession(generation, command);
      return !_disposed && generation == repository.sessionGeneration;
    } on StaleSessionException {
      return false;
    } catch (exception) {
      if (!_disposed && generation == repository.sessionGeneration) {
        error = exception is ApiException ? exception.message : '操作失败，请刷新核对数据';
      }
      return false;
    } finally {
      if (!_disposed) {
        saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_loadId;
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }
}
