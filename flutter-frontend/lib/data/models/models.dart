import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    @Default(0) int id,
    @Default('') String username,
    @Default('USER') String role,
    @Default('ACTIVE') String status,
    @Default(false) bool mustChangePassword,
    String? createdAt,
  }) = _UserProfile;
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
abstract class LoginResult with _$LoginResult {
  @JsonSerializable(explicitToJson: true)
  const factory LoginResult({
    required String token,
    required String expiresAt,
    required UserProfile user,
  }) = _LoginResult;
  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);
}

@freezed
abstract class UserPage with _$UserPage {
  @JsonSerializable(explicitToJson: true)
  const factory UserPage({
    @Default(<UserProfile>[]) List<UserProfile> records,
    @Default(0) int total,
  }) = _UserPage;
  factory UserPage.fromJson(Map<String, dynamic> json) =>
      _$UserPageFromJson(json);
}

@freezed
abstract class Account with _$Account {
  const factory Account({
    @Default(0) int id,
    @Default('') String name,
    @Default('') String type,
    @Default(0) num initialBalance,
    @Default(0) num currentBalance,
  }) = _Account;
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
}

@freezed
abstract class Category with _$Category {
  const factory Category({
    @Default(0) int id,
    @Default('') String name,
    @Default(1) int type,
    @Default(1) int isActive,
  }) = _Category;
  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
abstract class TransactionEntry with _$TransactionEntry {
  const factory TransactionEntry({
    @Default(0) int id,
    @Default(1) int type,
    @Default(0) int accountId,
    @Default(0) num amount,
    @Default('') String transactionDate,
    int? categoryId,
    int? toAccountId,
    int? liabilityId,
    String? remark,
  }) = _TransactionEntry;
  factory TransactionEntry.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntryFromJson(json);
}

@freezed
abstract class FixedItem with _$FixedItem {
  const factory FixedItem({
    @Default('') String id,
    @Default('') String name,
    @Default('EXPENSE') String type,
    @Default(0) num amount,
    int? expectedDay,
    int? accountId,
    int? liabilityId,
    int? transactionId,
    int? categoryId,
    String? categoryName,
    @Default(false) bool isBooked,
  }) = _FixedItem;
  factory FixedItem.fromJson(Map<String, dynamic> json) =>
      _$FixedItemFromJson(json);
}

@freezed
abstract class CycleTemplate with _$CycleTemplate {
  @JsonSerializable(explicitToJson: true)
  const factory CycleTemplate({
    @Default(0) int id,
    @Default(1) int startDay,
    @Default(0) int isDefault,
    @Default('') String name,
    @Default(<FixedItem>[]) List<FixedItem> fixedItems,
  }) = _CycleTemplate;
  factory CycleTemplate.fromJson(Map<String, dynamic> json) =>
      _$CycleTemplateFromJson(json);
}

@freezed
abstract class CycleRecord with _$CycleRecord {
  @JsonSerializable(explicitToJson: true)
  const factory CycleRecord({
    @Default(0) int id,
    @Default('') String cycleStartDate,
    @Default('') String cycleEndDate,
    @Default(<FixedItem>[]) List<FixedItem> fixedItems,
    @Default(0) num income,
    @Default(0) num expense,
    @Default(0) num balance,
  }) = _CycleRecord;
  factory CycleRecord.fromJson(Map<String, dynamic> json) =>
      _$CycleRecordFromJson(json);
}

@freezed
abstract class CategoryExpense with _$CategoryExpense {
  const factory CategoryExpense({
    @Default('') String name,
    @Default(0) num value,
  }) = _CategoryExpense;
  factory CategoryExpense.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpenseFromJson(json);
}

@freezed
abstract class Stats with _$Stats {
  @JsonSerializable(explicitToJson: true)
  const factory Stats({
    @Default(0) num totalAssets,
    @Default(0) num totalLiabilities,
    @Default(0) num availableAssets,
    @Default(0) num totalTargets,
    @Default(0) num targetAllocated,
    @Default(0) num currentIncome,
    @Default(0) num currentExpense,
    @Default(0) num currentFixedDeposit,
    @Default(0) num currentBalance,
    @Default(0) num currentFinalBalance,
    @Default(0) num cumulativeBalance,
    @Default(false) bool isOverdraft,
    @Default(<CategoryExpense>[]) List<CategoryExpense> categoryExpenses,
  }) = _Stats;
  factory Stats.fromJson(Map<String, dynamic> json) => _$StatsFromJson(json);
}

@freezed
abstract class Goal with _$Goal {
  const factory Goal({
    @Default(0) int id,
    @Default(0) int isRealized,
    @Default(0) int progress,
    @Default('') String name,
    @Default('LONG_TERM') String type,
    @Default(0) num targetAmount,
    @Default(0) num availableFunds,
    @Default(0) num gap,
    String? startDate,
    String? deadline,
    String? estimatedCompletionDate,
    String? estimatedReason,
    @Default(false) bool isEstimatedFallback,
  }) = _Goal;
  factory Goal.fromJson(Map<String, dynamic> json) => _$GoalFromJson(json);
}

@freezed
abstract class Liability with _$Liability {
  const factory Liability({
    @Default(0) int id,
    @Default('') String name,
    @Default(0) num principal,
    @Default(0) num totalAmount,
    @Default(1) int totalPeriods,
    @Default(0) int currentPeriod,
    @Default(0) num periodAmount,
    @Default('NONE') String rateType,
    @Default(0) num interestRate,
    @Default(1) int repaymentDay,
    String? nextRepaymentDate,
    int? defaultAccountId,
    int? categoryId,
    @Default(0) int autoCycleFixedExpense,
    @Default('REPAYING') String status,
    String? startDate,
    String? settledAt,
    String? createdAt,
    String? updatedAt,
    @Default(0) int remainingPeriods,
    @Default(0) num remainingAmount,
    @Default(0) int progressPercent,
    String? defaultAccountName,
    String? categoryName,
  }) = _Liability;
  factory Liability.fromJson(Map<String, dynamic> json) =>
      _$LiabilityFromJson(json);
}

@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    @Default(0) int id,
    @Default('') String type,
    @Default('') String title,
    @Default('') String content,
    @Default('') String bizId,
    @Default('PENDING') String status,
    String? createdAt,
  }) = _TodoItem;
  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}
