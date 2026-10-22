// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  role: json['role'] as String? ?? 'USER',
  status: json['status'] as String? ?? 'ACTIVE',
  mustChangePassword: json['mustChangePassword'] as bool? ?? false,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': instance.role,
      'status': instance.status,
      'mustChangePassword': instance.mustChangePassword,
      'createdAt': instance.createdAt,
    };

_LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => _LoginResult(
  token: json['token'] as String,
  expiresAt: json['expiresAt'] as String,
  user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginResultToJson(_LoginResult instance) =>
    <String, dynamic>{
      'token': instance.token,
      'expiresAt': instance.expiresAt,
      'user': instance.user.toJson(),
    };

_UserPage _$UserPageFromJson(Map<String, dynamic> json) => _UserPage(
  records:
      (json['records'] as List<dynamic>?)
          ?.map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <UserProfile>[],
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserPageToJson(_UserPage instance) => <String, dynamic>{
  'records': instance.records.map((e) => e.toJson()).toList(),
  'total': instance.total,
};

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  type: json['type'] as String? ?? '',
  initialBalance: json['initialBalance'] as num? ?? 0,
  currentBalance: json['currentBalance'] as num? ?? 0,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'initialBalance': instance.initialBalance,
  'currentBalance': instance.currentBalance,
};

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  type: (json['type'] as num?)?.toInt() ?? 1,
  isActive: (json['isActive'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'isActive': instance.isActive,
};

_TransactionEntry _$TransactionEntryFromJson(Map<String, dynamic> json) =>
    _TransactionEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 1,
      accountId: (json['accountId'] as num?)?.toInt() ?? 0,
      amount: json['amount'] as num? ?? 0,
      transactionDate: json['transactionDate'] as String? ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt(),
      toAccountId: (json['toAccountId'] as num?)?.toInt(),
      liabilityId: (json['liabilityId'] as num?)?.toInt(),
      remark: json['remark'] as String?,
    );

Map<String, dynamic> _$TransactionEntryToJson(_TransactionEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'accountId': instance.accountId,
      'amount': instance.amount,
      'transactionDate': instance.transactionDate,
      'categoryId': instance.categoryId,
      'toAccountId': instance.toAccountId,
      'liabilityId': instance.liabilityId,
      'remark': instance.remark,
    };

_FixedItem _$FixedItemFromJson(Map<String, dynamic> json) => _FixedItem(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  type: json['type'] as String? ?? 'EXPENSE',
  amount: json['amount'] as num? ?? 0,
  expectedDay: (json['expectedDay'] as num?)?.toInt(),
  accountId: (json['accountId'] as num?)?.toInt(),
  liabilityId: (json['liabilityId'] as num?)?.toInt(),
  transactionId: (json['transactionId'] as num?)?.toInt(),
  categoryId: (json['categoryId'] as num?)?.toInt(),
  categoryName: json['categoryName'] as String?,
  isBooked: json['isBooked'] as bool? ?? false,
);

Map<String, dynamic> _$FixedItemToJson(_FixedItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'amount': instance.amount,
      'expectedDay': instance.expectedDay,
      'accountId': instance.accountId,
      'liabilityId': instance.liabilityId,
      'transactionId': instance.transactionId,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'isBooked': instance.isBooked,
    };

_CycleTemplate _$CycleTemplateFromJson(Map<String, dynamic> json) =>
    _CycleTemplate(
      id: (json['id'] as num?)?.toInt() ?? 0,
      startDay: (json['startDay'] as num?)?.toInt() ?? 1,
      isDefault: (json['isDefault'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      fixedItems:
          (json['fixedItems'] as List<dynamic>?)
              ?.map((e) => FixedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <FixedItem>[],
    );

Map<String, dynamic> _$CycleTemplateToJson(_CycleTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDay': instance.startDay,
      'isDefault': instance.isDefault,
      'name': instance.name,
      'fixedItems': instance.fixedItems.map((e) => e.toJson()).toList(),
    };

_CycleRecord _$CycleRecordFromJson(Map<String, dynamic> json) => _CycleRecord(
  id: (json['id'] as num?)?.toInt() ?? 0,
  cycleStartDate: json['cycleStartDate'] as String? ?? '',
  cycleEndDate: json['cycleEndDate'] as String? ?? '',
  fixedItems:
      (json['fixedItems'] as List<dynamic>?)
          ?.map((e) => FixedItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FixedItem>[],
  income: json['income'] as num? ?? 0,
  expense: json['expense'] as num? ?? 0,
  balance: json['balance'] as num? ?? 0,
);

Map<String, dynamic> _$CycleRecordToJson(_CycleRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cycleStartDate': instance.cycleStartDate,
      'cycleEndDate': instance.cycleEndDate,
      'fixedItems': instance.fixedItems.map((e) => e.toJson()).toList(),
      'income': instance.income,
      'expense': instance.expense,
      'balance': instance.balance,
    };

_CategoryExpense _$CategoryExpenseFromJson(Map<String, dynamic> json) =>
    _CategoryExpense(
      name: json['name'] as String? ?? '',
      value: json['value'] as num? ?? 0,
    );

Map<String, dynamic> _$CategoryExpenseToJson(_CategoryExpense instance) =>
    <String, dynamic>{'name': instance.name, 'value': instance.value};

_Stats _$StatsFromJson(Map<String, dynamic> json) => _Stats(
  totalAssets: json['totalAssets'] as num? ?? 0,
  totalLiabilities: json['totalLiabilities'] as num? ?? 0,
  availableAssets: json['availableAssets'] as num? ?? 0,
  totalTargets: json['totalTargets'] as num? ?? 0,
  targetAllocated: json['targetAllocated'] as num? ?? 0,
  currentIncome: json['currentIncome'] as num? ?? 0,
  currentExpense: json['currentExpense'] as num? ?? 0,
  currentFixedDeposit: json['currentFixedDeposit'] as num? ?? 0,
  currentBalance: json['currentBalance'] as num? ?? 0,
  currentFinalBalance: json['currentFinalBalance'] as num? ?? 0,
  cumulativeBalance: json['cumulativeBalance'] as num? ?? 0,
  isOverdraft: json['isOverdraft'] as bool? ?? false,
  categoryExpenses:
      (json['categoryExpenses'] as List<dynamic>?)
          ?.map((e) => CategoryExpense.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CategoryExpense>[],
);

Map<String, dynamic> _$StatsToJson(_Stats instance) => <String, dynamic>{
  'totalAssets': instance.totalAssets,
  'totalLiabilities': instance.totalLiabilities,
  'availableAssets': instance.availableAssets,
  'totalTargets': instance.totalTargets,
  'targetAllocated': instance.targetAllocated,
  'currentIncome': instance.currentIncome,
  'currentExpense': instance.currentExpense,
  'currentFixedDeposit': instance.currentFixedDeposit,
  'currentBalance': instance.currentBalance,
  'currentFinalBalance': instance.currentFinalBalance,
  'cumulativeBalance': instance.cumulativeBalance,
  'isOverdraft': instance.isOverdraft,
  'categoryExpenses': instance.categoryExpenses.map((e) => e.toJson()).toList(),
};

_Goal _$GoalFromJson(Map<String, dynamic> json) => _Goal(
  id: (json['id'] as num?)?.toInt() ?? 0,
  isRealized: (json['isRealized'] as num?)?.toInt() ?? 0,
  progress: (json['progress'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  type: json['type'] as String? ?? 'LONG_TERM',
  targetAmount: json['targetAmount'] as num? ?? 0,
  availableFunds: json['availableFunds'] as num? ?? 0,
  gap: json['gap'] as num? ?? 0,
  startDate: json['startDate'] as String?,
  deadline: json['deadline'] as String?,
  estimatedCompletionDate: json['estimatedCompletionDate'] as String?,
  estimatedReason: json['estimatedReason'] as String?,
  isEstimatedFallback: json['isEstimatedFallback'] as bool? ?? false,
);

Map<String, dynamic> _$GoalToJson(_Goal instance) => <String, dynamic>{
  'id': instance.id,
  'isRealized': instance.isRealized,
  'progress': instance.progress,
  'name': instance.name,
  'type': instance.type,
  'targetAmount': instance.targetAmount,
  'availableFunds': instance.availableFunds,
  'gap': instance.gap,
  'startDate': instance.startDate,
  'deadline': instance.deadline,
  'estimatedCompletionDate': instance.estimatedCompletionDate,
  'estimatedReason': instance.estimatedReason,
  'isEstimatedFallback': instance.isEstimatedFallback,
};

_Liability _$LiabilityFromJson(Map<String, dynamic> json) => _Liability(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  principal: json['principal'] as num? ?? 0,
  totalAmount: json['totalAmount'] as num? ?? 0,
  totalPeriods: (json['totalPeriods'] as num?)?.toInt() ?? 1,
  currentPeriod: (json['currentPeriod'] as num?)?.toInt() ?? 0,
  periodAmount: json['periodAmount'] as num? ?? 0,
  rateType: json['rateType'] as String? ?? 'NONE',
  interestRate: json['interestRate'] as num? ?? 0,
  repaymentDay: (json['repaymentDay'] as num?)?.toInt() ?? 1,
  nextRepaymentDate: json['nextRepaymentDate'] as String?,
  defaultAccountId: (json['defaultAccountId'] as num?)?.toInt(),
  categoryId: (json['categoryId'] as num?)?.toInt(),
  autoCycleFixedExpense: (json['autoCycleFixedExpense'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'REPAYING',
  startDate: json['startDate'] as String?,
  settledAt: json['settledAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  remainingPeriods: (json['remainingPeriods'] as num?)?.toInt() ?? 0,
  remainingAmount: json['remainingAmount'] as num? ?? 0,
  progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
  defaultAccountName: json['defaultAccountName'] as String?,
  categoryName: json['categoryName'] as String?,
);

Map<String, dynamic> _$LiabilityToJson(_Liability instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'principal': instance.principal,
      'totalAmount': instance.totalAmount,
      'totalPeriods': instance.totalPeriods,
      'currentPeriod': instance.currentPeriod,
      'periodAmount': instance.periodAmount,
      'rateType': instance.rateType,
      'interestRate': instance.interestRate,
      'repaymentDay': instance.repaymentDay,
      'nextRepaymentDate': instance.nextRepaymentDate,
      'defaultAccountId': instance.defaultAccountId,
      'categoryId': instance.categoryId,
      'autoCycleFixedExpense': instance.autoCycleFixedExpense,
      'status': instance.status,
      'startDate': instance.startDate,
      'settledAt': instance.settledAt,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'remainingPeriods': instance.remainingPeriods,
      'remainingAmount': instance.remainingAmount,
      'progressPercent': instance.progressPercent,
      'defaultAccountName': instance.defaultAccountName,
      'categoryName': instance.categoryName,
    };

_TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => _TodoItem(
  id: (json['id'] as num?)?.toInt() ?? 0,
  type: json['type'] as String? ?? '',
  title: json['title'] as String? ?? '',
  content: json['content'] as String? ?? '',
  bizId: json['bizId'] as String? ?? '',
  status: json['status'] as String? ?? 'PENDING',
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$TodoItemToJson(_TodoItem instance) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'title': instance.title,
  'content': instance.content,
  'bizId': instance.bizId,
  'status': instance.status,
  'createdAt': instance.createdAt,
};
