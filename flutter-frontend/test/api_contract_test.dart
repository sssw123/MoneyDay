import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/repositories/moneyday_repository.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/data/services/session_controller.dart';

ResponseBody responseBody(
  Object? data, {
  int status = 200,
  int code = 200,
  String message = 'success',
}) => ResponseBody.fromString(
  jsonEncode({'code': code, 'message': message, 'data': data}),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Records the actual serialized transport body without requiring a local server.
class RecordingAdapter implements HttpClientAdapter {
  FutureOr<ResponseBody> Function(RequestOptions) handler = (_) =>
      responseBody(null);
  final List<RequestOptions> calls = [];
  final List<Object?> bodies = [];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final bytes = await requestStream?.fold<List<int>>(
      [],
      (result, part) => result..addAll(part),
    );
    bodies.add(
      bytes == null || bytes.isEmpty ? null : jsonDecode(utf8.decode(bytes)),
    );
    return await handler(options);
  }

  @override
  void close({bool force = false}) {}
}

LoginResult sessionValue({
  int id = 1,
  String token = 'token-a',
  bool mustChangePassword = false,
  String role = 'USER',
  String? expiresAt,
}) => LoginResult(
  token: token,
  expiresAt:
      expiresAt ??
      DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String(),
  user: UserProfile(
    id: id,
    username: 'user-$id',
    role: role,
    mustChangePassword: mustChangePassword,
  ),
);

class TestHarness {
  TestHarness({SessionController? session})
    : session = session ?? SessionController(store: MemorySessionStore()) {
    final dio = Dio()..httpClientAdapter = adapter;
    api = ApiClient(
      session: this.session,
      dio: dio,
      baseUrl: 'https://ledger.example/api',
    );
    repository = MoneydayRepository(api: api);
  }
  final SessionController session;
  final RecordingAdapter adapter = RecordingAdapter();
  late final ApiClient api;
  late final MoneydayRepository repository;
  void dispose() {
    repository.dispose();
    api.dispose();
    session.dispose();
  }
}

void main() {
  late TestHarness h;
  setUp(() {
    h = TestHarness();
    h.session.setSession(sessionValue());
  });
  tearDown(() => h.dispose());

  group('查询 API 契约', () {
    final cases =
        <(String, Future<dynamic> Function(), Object?, Map<String, Object?>)>[
          ('/accounts', () => h.repository.accounts(), [], {}),
          ('/categories', () => h.repository.categories(), [], {}),
          ('/transactions', () => h.repository.transactions(), [], {}),
          ('/cycles', () => h.repository.cycles(), [], {}),
          ('/cycle-templates', () => h.repository.templates(), [], {}),
          ('/stats', () => h.repository.stats(), {}, {}),
          ('/targets', () => h.repository.goals(wishlist: false), [], {}),
          ('/wishlists', () => h.repository.goals(wishlist: true), [], {}),
          ('/liabilities', () => h.repository.liabilities(), [], {}),
          ('/todos', () => h.repository.todos(), [], {'status': 'PENDING'}),
          (
            '/todos',
            () => h.repository.todos(status: 'RESOLVED'),
            [],
            {'status': 'RESOLVED'},
          ),
          (
            '/todos/pending-count',
            () => h.repository.pendingCount(),
            {'count': 3},
            {},
          ),
          (
            '/admin/users',
            () => h.repository.users(),
            {'records': [], 'total': 0},
            {'page': 1, 'pageSize': 20, 'keyword': ''},
          ),
          (
            '/admin/users',
            () => h.repository.users(
              page: 2,
              pageSize: 10,
              keyword: '测试',
              status: 'DISABLED',
            ),
            {'records': [], 'total': 0},
            {'page': 2, 'pageSize': 10, 'keyword': '测试', 'status': 'DISABLED'},
          ),
        ];
    for (var index = 0; index < cases.length; index++) {
      final (path, run, data, query) = cases[index];
      test('$index GET $path', () async {
        var notifications = 0;
        h.repository.addListener(() => notifications++);
        h.adapter.handler = (_) => responseBody(data);
        final value = await run();
        final request = h.adapter.calls.single;
        expect(request.method, 'GET');
        expect(request.uri.path, '/api$path');
        expect(request.queryParameters, query);
        expect(request.headers['Authorization'], 'Bearer token-a');
        expect(h.adapter.bodies.single, isNull);
        expect(notifications, 0);
        if (path == '/todos/pending-count') expect(value, 3);
      });
    }
  });

  group('增删改 API 契约', () {
    const body = <String, Object?>{
      'name': '测试',
      'amount': 12.5,
      'categoryId': null,
    };
    final crud =
        <
          (String, Future<void> Function({int? id}), Future<void> Function(int))
        >[
          (
            '/accounts',
            ({id}) => h.repository.saveAccount(body, id: id),
            (id) => h.repository.deleteAccount(id),
          ),
          (
            '/categories',
            ({id}) => h.repository.saveCategory(body, id: id),
            (id) => h.repository.deleteCategory(id),
          ),
          (
            '/transactions',
            ({id}) => h.repository.saveTransaction(body, id: id),
            (id) => h.repository.deleteTransaction(id),
          ),
          (
            '/cycle-templates',
            ({id}) => h.repository.saveTemplate(body, id: id),
            (id) => h.repository.deleteTemplate(id),
          ),
          (
            '/liabilities',
            ({id}) => h.repository.saveLiability(body, id: id),
            (id) => h.repository.deleteLiability(id),
          ),
          (
            '/targets',
            ({id}) => h.repository.saveGoal(body, id: id, wishlist: false),
            (id) => h.repository.deleteGoal(id, wishlist: false),
          ),
          (
            '/wishlists',
            ({id}) => h.repository.saveGoal(body, id: id, wishlist: true),
            (id) => h.repository.deleteGoal(id, wishlist: true),
          ),
        ];
    for (final (path, save, delete) in crud) {
      test('$path 创建、更新、删除仅各发送一次并刷新', () async {
        var notifications = 0;
        h.repository.addListener(() => notifications++);
        await save();
        await save(id: 7);
        await delete(7);
        expect(h.adapter.calls.map((r) => (r.method, r.uri.path)), [
          ('POST', '/api$path'),
          ('PUT', '/api$path/7'),
          ('DELETE', '/api$path/7'),
        ]);
        expect(h.adapter.bodies, [body, body, null]);
        expect(notifications, 3);
      });
    }
    final commands = <(String, String, Future<void> Function(), Object?)>[
      (
        'POST',
        '/cycle-templates/7/default',
        () => h.repository.defaultTemplate(7),
        null,
      ),
      (
        'POST',
        '/cycles/7/book-item/fixed-item',
        () => h.repository.bookItem(
          7,
          'fixed-item',
          accountId: 2,
          amount: 123.45,
          date: '2026-10-22',
        ),
        {'accountId': 2, 'amount': 123.45, 'date': '2026-10-22'},
      ),
      (
        'POST',
        '/cycles/7/unbook-item/fixed-item',
        () => h.repository.unbookItem(7, 'fixed-item'),
        null,
      ),
      (
        'PUT',
        '/cycles/7/fixed-deposit',
        () => h.repository.updateFixedDeposit(7, 200),
        {'fixedDeposit': 200},
      ),
      (
        'POST',
        '/targets/7/realize',
        () => h.repository.realizeGoal(7, 2, wishlist: false),
        {'accountId': 2},
      ),
      (
        'POST',
        '/targets/7/unrealize',
        () => h.repository.unrealizeGoal(7, wishlist: false),
        null,
      ),
      (
        'POST',
        '/wishlists/7/realize',
        () => h.repository.realizeGoal(7, 2, wishlist: true),
        {'accountId': 2},
      ),
      (
        'POST',
        '/wishlists/7/unrealize',
        () => h.repository.unrealizeGoal(7, wishlist: true),
        null,
      ),
      (
        'POST',
        '/liabilities/7/repay',
        () => h.repository.repay(7, accountId: 2, periods: 3, amount: 345),
        {'accountId': 2, 'periods': 3, 'amount': 345},
      ),
      (
        'POST',
        '/liabilities/7/settle',
        () => h.repository.settle(7, accountId: 2, amount: 500.25),
        {'accountId': 2, 'settleAmount': 500.25},
      ),
      ('POST', '/todos/7/dismiss', () => h.repository.dismissTodo(7), null),
      ('POST', '/todos/7/resolve', () => h.repository.resolveTodo(7), null),
      ('POST', '/todos/7/retry-repay', () => h.repository.retryRepay(7), {}),
      (
        'POST',
        '/todos/7/retry-repay',
        () => h.repository.retryRepay(7, accountId: 2),
        {'accountId': 2},
      ),
      (
        'POST',
        '/admin/users',
        () => h.repository.createUser('新用户', 'Password123'),
        {'username': '新用户', 'password': 'Password123'},
      ),
      (
        'PUT',
        '/admin/users/7/status',
        () => h.repository.updateUserStatus(7, 'DISABLED'),
        {'status': 'DISABLED'},
      ),
      (
        'POST',
        '/admin/users/7/reset-password',
        () => h.repository.resetUserPassword(7, 'NewPassword123'),
        {'password': 'NewPassword123'},
      ),
      ('DELETE', '/admin/users/7', () => h.repository.deleteUser(7), null),
    ];
    for (var index = 0; index < commands.length; index++) {
      final (method, path, run, payload) = commands[index];
      test('$index $method $path', () async {
        var notifications = 0;
        h.repository.addListener(() => notifications++);
        await run();
        expect(h.adapter.calls.single.method, method);
        expect(h.adapter.calls.single.uri.path, '/api$path');
        expect(
          h.adapter.calls.single.headers['Authorization'],
          'Bearer token-a',
        );
        expect(h.adapter.bodies.single, payload);
        expect(notifications, 1);
      });
    }
  });

  group('错误与不重放', () {
    test('HTTP 200 的业务失败仍拒绝，保持服务端消息', () async {
      h.adapter.handler = (_) =>
          responseBody(null, code: 409, message: '该固定项目已到账');
      await expectLater(
        h.repository.bookItem(
          1,
          'x',
          accountId: 1,
          amount: 10,
          date: '2026-10-22',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.code, 'code', 409)
              .having((e) => e.message, 'message', '该固定项目已到账'),
        ),
      );
      expect(h.adapter.calls, hasLength(1));
    });
    test('HTTP 失败优先于成功包络', () async {
      h.adapter.handler = (_) => responseBody(null, status: 503);
      await expectLater(
        h.repository.accounts(),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', 503)),
      );
    });
    test('拒绝缺少包络的成功响应', () async {
      h.adapter.handler = (_) => ResponseBody.fromString(
        '{}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
      await expectLater(
        h.repository.accounts(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('格式'),
          ),
        ),
      );
    });
    test('拒绝非法字符串业务 code，统一返回格式错误', () async {
      h.adapter.handler = (_) => ResponseBody.fromString(
        '{"code":"200","data":[]}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
      await expectLater(
        h.repository.accounts(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('格式'),
          ),
        ),
      );
    });
    test('财务写入超时只发送一次，不通知刷新，明确结果未知', () async {
      var notifications = 0;
      h.repository.addListener(() => notifications++);
      h.adapter.handler = (request) => throw DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      );
      await expectLater(
        h.repository.repay(1, accountId: 2, periods: 1, amount: 20),
        throwsA(
          isA<ApiException>()
              .having((e) => e.uncertain, 'uncertain', isTrue)
              .having((e) => e.message, 'message', contains('刷新核对')),
        ),
      );
      expect(h.adapter.calls, hasLength(1));
      expect(notifications, 0);
    });
    test('读取断网可刷新，但不自动重试', () async {
      h.adapter.handler = (request) => throw DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      );
      await expectLater(
        h.repository.accounts(),
        throwsA(
          isA<ApiException>()
              .having((e) => e.uncertain, 'uncertain', isFalse)
              .having((e) => e.message, 'message', contains('刷新重试')),
        ),
      );
      expect(h.adapter.calls, hasLength(1));
    });
    for (final code in [401, 403]) {
      test('$code 传递给身份处理器', () async {
        final errors = <(int, int)>[];
        h.api.onAuthError = (code, generation) async =>
            errors.add((code, generation));
        h.adapter.handler = (_) =>
            responseBody(null, status: code, code: code, message: '拒绝访问');
        await expectLater(
          h.repository.accounts(),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', code)),
        );
        expect(errors, [(code, h.session.generation)]);
      });
    }
  });
}
