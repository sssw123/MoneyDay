import 'package:moneyday/data/models/models.dart';
import 'package:moneyday/data/services/api_client.dart';
import 'package:moneyday/ui/core/feature_view_model.dart';

/// Data for each screen is committed together, only for the originating user.
class AccountsViewModel extends FeatureViewModel {
  AccountsViewModel(super.repository);
  List<Account> accounts = [];
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await repository.accounts();
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    accounts = result;
  }

  Future<void> save(Map<String, Object?> body, {int? id}) =>
      repository.saveAccount(body, id: id);
  Future<bool> remove(Account account) =>
      run(() => repository.deleteAccount(account.id));
}

class CategoriesViewModel extends FeatureViewModel {
  CategoriesViewModel(super.repository);
  List<Category> categories = [];
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await repository.categories();
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    categories = result;
  }

  Future<void> save(Map<String, Object?> body, {int? id}) =>
      repository.saveCategory(body, id: id);
  Future<bool> remove(Category category) =>
      run(() => repository.deleteCategory(category.id));
  Future<bool> toggle(Category category, bool enabled) => run(
    () => repository.saveCategory({
      'name': category.name,
      'type': category.type,
      'isActive': enabled ? 1 : 0,
    }, id: category.id),
  );
}

class TransactionsViewModel extends FeatureViewModel {
  TransactionsViewModel(super.repository);
  List<TransactionEntry> transactions = [];
  List<Account> accounts = [];
  List<Category> categories = [];
  int? typeFilter;
  String search = '';
  List<TransactionEntry> get filtered => transactions.where((entry) {
    final haystack =
        '${entry.remark ?? ''} ${accountName(entry.accountId)} ${accountName(entry.toAccountId)} ${categoryName(entry.categoryId)} ${entry.transactionDate}';
    return (typeFilter == null || entry.type == typeFilter) &&
        haystack.toLowerCase().contains(search.toLowerCase());
  }).toList();
  void filter(int? type) {
    typeFilter = type;
    notifyListeners();
  }

  void searchFor(String value) {
    search = value;
    notifyListeners();
  }

  String accountName(int? id) =>
      accounts.where((account) => account.id == id).firstOrNull?.name ?? '—';
  String categoryName(int? id) =>
      categories.where((category) => category.id == id).firstOrNull?.name ??
      '—';
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await Future.wait<Object>([
      repository.transactions(),
      repository.accounts(),
      repository.categories(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    transactions = result[0] as List<TransactionEntry>;
    accounts = result[1] as List<Account>;
    categories = result[2] as List<Category>;
  }

  Future<void> save(Map<String, Object?> body, {int? id}) =>
      repository.saveTransaction(body, id: id);
  Future<bool> remove(TransactionEntry entry) =>
      run(() => repository.deleteTransaction(entry.id));
}

class BudgetViewModel extends FeatureViewModel {
  BudgetViewModel(super.repository);
  List<CycleRecord> cycles = [];
  List<Account> accounts = [];
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await Future.wait<Object>([
      repository.cycles(),
      repository.accounts(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    cycles = result[0] as List<CycleRecord>;
    accounts = result[1] as List<Account>;
  }

  Future<void> book(
    CycleRecord cycle,
    FixedItem item, {
    required int accountId,
    required num amount,
    required String date,
  }) => repository.bookItem(
    cycle.id,
    item.id,
    accountId: accountId,
    amount: amount,
    date: date,
  );
  Future<bool> unbook(CycleRecord cycle, FixedItem item) =>
      run(() => repository.unbookItem(cycle.id, item.id));
}

class SettingsViewModel extends FeatureViewModel {
  SettingsViewModel(super.repository);
  List<CycleTemplate> templates = [];
  List<Category> categories = [];
  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await Future.wait<Object>([
      repository.templates(),
      repository.categories(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    templates = result[0] as List<CycleTemplate>;
    categories = result[1] as List<Category>;
  }

  Future<void> save(Map<String, Object?> body, {int? id}) =>
      repository.saveTemplate(body, id: id);
  Future<bool> remove(CycleTemplate template) =>
      run(() => repository.deleteTemplate(template.id));
  Future<bool> makeDefault(CycleTemplate template) =>
      run(() => repository.defaultTemplate(template.id));
}

class DashboardViewModel extends FeatureViewModel {
  DashboardViewModel(super.repository);
  Stats? stats;
  bool amountsVisible = true;
  List<CycleRecord> cycles = [];
  List<Account> accounts = [];
  List<Goal> targets = [];
  List<Goal> wishlists = [];
  List<Liability> liabilities = [];
  void toggleAmounts() {
    amountsVisible = !amountsVisible;
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    final generation = repository.sessionGeneration;
    final result = await Future.wait<Object>([
      repository.stats(),
      repository.cycles(),
      repository.accounts(),
      repository.goals(wishlist: false),
      repository.goals(wishlist: true),
      repository.liabilities(),
    ]);
    if (generation != repository.sessionGeneration) {
      throw const StaleSessionException();
    }
    stats = result[0] as Stats;
    cycles = result[1] as List<CycleRecord>;
    accounts = result[2] as List<Account>;
    targets = result[3] as List<Goal>;
    wishlists = result[4] as List<Goal>;
    liabilities = result[5] as List<Liability>;
  }

  Future<void> realize(Goal goal, int accountId, {required bool wishlist}) =>
      repository.realizeGoal(goal.id, accountId, wishlist: wishlist);
  Future<bool> unrealize(Goal goal, {required bool wishlist}) =>
      run(() => repository.unrealizeGoal(goal.id, wishlist: wishlist));
}
