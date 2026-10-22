import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'session_controller.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.uncertain = false});
  final String message;
  final int? code;
  final bool uncertain;
  @override
  String toString() => message;
}

class StaleSessionException implements Exception {
  const StaleSessionException();
}

/// A request is sent once. In particular, writes are never automatically replayed.
class ApiClient {
  static final Object _sessionGenerationZoneKey = Object();
  static Future<T> inSession<T>(
    int generation,
    Future<T> Function() operation,
  ) => runZoned(operation, zoneValues: {_sessionGenerationZoneKey: generation});

  ApiClient({required this.session, Dio? dio, String? baseUrl})
    : dio = dio ?? Dio(),
      baseUrl = resolveBaseUrl(baseUrl) {
    this.dio.options
      ..baseUrl = this.baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 30)
      ..sendTimeout = const Duration(seconds: 30)
      ..validateStatus = ((status) => status != null && status < 600);
    _generation = session.generation;
    session.addListener(_sessionChanged);
  }
  final SessionController session;
  final Dio dio;
  final String baseUrl;
  final Set<CancelToken> _pending = {};
  late int _generation;
  Future<void> Function(int code, int generation)? onAuthError;

  static String resolveBaseUrl(
    String? override, {
    bool web = kIsWeb,
    bool release = kReleaseMode,
  }) {
    const configured = String.fromEnvironment('API_BASE_URL');
    final raw = (override ?? configured).trim().replaceAll(RegExp(r'/+$'), '');
    if (web && (raw.isEmpty || raw == '/api')) return '/api';
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        !{'https', 'http'}.contains(uri.scheme)) {
      throw const ApiException('请通过 API_BASE_URL 配置完整的 API 地址（以 /api 结尾）');
    }
    if (release && uri.scheme != 'https') {
      throw const ApiException('正式构建的 API_BASE_URL 必须使用 HTTPS');
    }
    if (uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty) {
      throw const ApiException('API_BASE_URL 不支持查询参数、片段或用户信息');
    }
    return raw.endsWith('/api') ? raw : '$raw/api';
  }

  void _sessionChanged() {
    if (_generation == session.generation) return;
    _generation = session.generation;
    for (final token in _pending.toList()) {
      token.cancel('session changed');
    }
    _pending.clear();
  }

  Future<dynamic> request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool authenticated = true,
    bool handleAuthError = true,
    String? capturedToken,
    bool isolate = true,
  }) async {
    final generation = session.generation;
    final originatingGeneration =
        Zone.current[_sessionGenerationZoneKey] as int?;
    if (authenticated &&
        isolate &&
        originatingGeneration != null &&
        originatingGeneration != generation) {
      throw const StaleSessionException();
    }
    final cancelToken = CancelToken();
    if (isolate) _pending.add(cancelToken);
    final token = capturedToken ?? session.token;
    try {
      final response = await dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          headers: {
            if (authenticated && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      if (isolate && generation != session.generation) {
        throw const StaleSessionException();
      }
      final body = response.data;
      final status = response.statusCode ?? 500;
      final rawCode = body is Map ? body['code'] : null;
      final code = rawCode is num ? rawCode.toInt() : status;
      if (status < 200 || status >= 300 || code != 200) {
        final errorCode = status < 200 || status >= 300 ? status : code;
        if (authenticated &&
            handleAuthError &&
            isolate &&
            (errorCode == 401 || errorCode == 403)) {
          await onAuthError?.call(errorCode, generation);
        }
        if (isolate && generation != session.generation) {
          throw const StaleSessionException();
        }
        throw ApiException(
          body is Map ? body['message']?.toString() ?? '请求失败' : '服务器响应异常',
          code: errorCode,
        );
      }
      if (body is! Map || rawCode is! num) {
        throw const ApiException('服务器响应格式异常');
      }
      return body['data'];
    } on DioException catch (error) {
      if (isolate &&
          (generation != session.generation || CancelToken.isCancel(error))) {
        throw const StaleSessionException();
      }
      final writing = method != 'GET';
      throw ApiException(
        writing ? '网络异常，操作结果尚未确认。请刷新核对后再决定是否重新操作。' : '无法连接服务器，请检查网络后刷新重试。',
        uncertain: writing,
      );
    } finally {
      _pending.remove(cancelToken);
    }
  }

  void dispose() {
    session.removeListener(_sessionChanged);
    for (final token in _pending) {
      token.cancel();
    }
    _pending.clear();
    dio.close();
  }
}
