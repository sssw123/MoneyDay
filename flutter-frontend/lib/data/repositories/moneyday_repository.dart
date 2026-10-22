import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/models.dart';
import '../services/api_client.dart';

class MoneydayRepository extends ChangeNotifier {
  MoneydayRepository({required this.api}) {
    _generation = api.session.generation;
    api.session.addListener(_sessionChanged);
  }
  final ApiClient api;
  late int _generation;
  int get sessionGeneration => api.session.generation;
  bool get authenticated => api.session.signedIn;
  void _sessionChanged() {
    if (_generation == sessionGeneration) return;
    _generation = sessionGeneration;
    notifyListeners();
  }

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) async {
    final data = await api.request('GET', path, query: query);
    return (data as List)
        .map((value) => parse(Map<String, dynamic>.from(value as Map)))
        .toList();
  }

  Future<void> _write(String method, String path, [Object? body]) async {
    await api.request(method, path, data: body);
    notifyListeners();
  }

  Future<void> _save(String path, Map<String, Object?> body, int? id) => _write(
    id == null ? 'POST' : 'PUT',
    id == null ? path : '$path/$id',
    body,
  );

  Future<List<Account>> accounts() => _list('/accounts', Account.fromJson);
  Future<List<Category>> categories() =>
      _list('/categories', Category.fromJson);
  Future<List<TransactionEntry>> transactions() =>
      _list('/transactions', TransactionEntry.fromJson);
  Future<List<CycleRecord>> cycles() => _list('/cycles', CycleRecord.fromJson);
  Future<List<CycleTemplate>> templates() =>
      _list('/cycle-templates', CycleTemplate.fromJson);
  Future<Stats> stats() async => Stats.fromJson(
    Map<String, dynamic>.from(await api.request('GET', '/stats') as Map),
  );
  Future<List<Goal>> goals({required bool wishlist}) =>
      _list(wishlist ? '/wishlists' : '/targets', Goal.fromJson);
  Future<List<Liability>> liabilities() =>
      _list('/liabilities', Liability.fromJson);
  Future<List<TodoItem>> todos({String status = 'PENDING'}) =>
      _list('/todos', TodoItem.fromJson, query: {'status': status});
  Future<int> pendingCount() async {
    final value = await api.request('GET', '/todos/pending-count');
    return (value['count'] as num).toInt();
  }

  Future<UserPage> users({
    int page = 1,
    int pageSize = 20,
    String keyword = '',
    String? status,
  }) async => UserPage.fromJson(
    Map<String, dynamic>.from(
      await api.request(
            'GET',
            '/admin/users',
            query: {
              'page': page,
              'pageSize': pageSize,
              'keyword': keyword,
              'status': ?status,
            },
          )
          as Map,
    ),
  );

  Future<void> saveAccount(Map<String, Object?> body, {int? id}) =>
      _save('/accounts', body, id);
  Future<void> saveCategory(Map<String, Object?> body, {int? id}) =>
      _save('/categories', body, id);
  Future<void> saveTransaction(Map<String, Object?> body, {int? id}) =>
      _save('/transactions', body, id);
  Future<void> saveTemplate(Map<String, Object?> body, {int? id}) =>
      _save('/cycle-templates', body, id);
  Future<void> saveLiability(Map<String, Object?> body, {int? id}) =>
      _save('/liabilities', body, id);
  Future<void> saveGoal(
    Map<String, Object?> body, {
    int? id,
    required bool wishlist,
  }) => _save(wishlist ? '/wishlists' : '/targets', body, id);
  Future<void> deleteAccount(int id) => _write('DELETE', '/accounts/$id');
  Future<void> deleteCategory(int id) => _write('DELETE', '/categories/$id');
  Future<void> deleteTransaction(int id) =>
      _write('DELETE', '/transactions/$id');
  Future<void> deleteTemplate(int id) =>
      _write('DELETE', '/cycle-templates/$id');
  Future<void> deleteLiability(int id) => _write('DELETE', '/liabilities/$id');
  Future<void> deleteGoal(int id, {required bool wishlist}) =>
      _write('DELETE', '${wishlist ? '/wishlists' : '/targets'}/$id');
  Future<void> defaultTemplate(int id) =>
      _write('POST', '/cycle-templates/$id/default');
  Future<void> bookItem(
    int cycleId,
    String itemId, {
    required int accountId,
    required num amount,
    required String date,
  }) => _write(
    'POST',
    '/cycles/$cycleId/book-item/${Uri.encodeComponent(itemId)}',
    {'accountId': accountId, 'amount': amount, 'date': date},
  );
  Future<void> unbookItem(int cycleId, String itemId) => _write(
    'POST',
    '/cycles/$cycleId/unbook-item/${Uri.encodeComponent(itemId)}',
  );
  Future<void> updateFixedDeposit(int cycleId, num amount) =>
      _write('PUT', '/cycles/$cycleId/fixed-deposit', {'fixedDeposit': amount});
  Future<void> realizeGoal(int id, int accountId, {required bool wishlist}) =>
      _write('POST', '${wishlist ? '/wishlists' : '/targets'}/$id/realize', {
        'accountId': accountId,
      });
  Future<void> unrealizeGoal(int id, {required bool wishlist}) =>
      _write('POST', '${wishlist ? '/wishlists' : '/targets'}/$id/unrealize');
  Future<void> repay(
    int id, {
    required int accountId,
    required int periods,
    required num amount,
  }) => _write('POST', '/liabilities/$id/repay', {
    'accountId': accountId,
    'periods': periods,
    'amount': amount,
  });
  Future<void> settle(int id, {required int accountId, required num amount}) =>
      _write('POST', '/liabilities/$id/settle', {
        'accountId': accountId,
        'settleAmount': amount,
      });
  Future<void> dismissTodo(int id) => _write('POST', '/todos/$id/dismiss');
  Future<void> resolveTodo(int id) => _write('POST', '/todos/$id/resolve');
  Future<void> retryRepay(int id, {int? accountId}) =>
      _write('POST', '/todos/$id/retry-repay', {'accountId': ?accountId});
  Future<void> createUser(String username, String password) => _write(
    'POST',
    '/admin/users',
    {'username': username, 'password': password},
  );
  Future<void> updateUserStatus(int id, String status) =>
      _write('PUT', '/admin/users/$id/status', {'status': status});
  Future<void> resetUserPassword(int id, String password) =>
      _write('POST', '/admin/users/$id/reset-password', {'password': password});
  Future<void> deleteUser(int id) => _write('DELETE', '/admin/users/$id');
  @override
  void dispose() {
    api.session.removeListener(_sessionChanged);
    super.dispose();
  }
}
