<template>
  <div class="transactions-page">
    <van-nav-bar title="记账明细" fixed placeholder>
      <template #right>
        <van-icon name="plus" size="18" @click="openAddPopup" />
      </template>
    </van-nav-bar>

    <van-pull-refresh v-model="refreshing" @refresh="fetchData">
      <div v-if="transactions.length === 0" style="padding: 60px 0; text-align: center;">
        <van-empty description="暂无记账流水，点击右上角记一笔吧！" />
      </div>

      <div v-else class="tx-list">
        <van-swipe-cell v-for="item in transactions" :key="item.id">
          <div class="tx-item">
            <div class="tx-left">
              <div class="tx-title">
                <span class="tx-cat">{{ getCategoryName(item.categoryId) }}</span>
                <span class="tx-remark" v-if="item.remark">{{ item.remark }}</span>
              </div>
              <div class="tx-meta">
                <span>{{ item.transactionDate }}</span>
                <span>·</span>
                <span>{{ getAccountName(item.accountId) }}</span>
                <span v-if="item.type === 3"> ➔ {{ getAccountName(item.toAccountId) }}</span>
              </div>
            </div>
            <div class="tx-right" :class="getAmountClass(item.type)">
              {{ getAmountPrefix(item.type) }}¥{{ formatNum(item.amount) }}
            </div>
          </div>

          <template #right>
            <van-button square type="danger" text="删除" class="delete-btn" @click="handleDelete(item.id)" />
          </template>
        </van-swipe-cell>
      </div>
    </van-pull-refresh>

    <!-- 记账浮动按钮 -->
    <div class="fab-btn" @click="openAddPopup">
      <van-icon name="edit" size="22" />
    </div>

    <!-- 移动端记账弹出层 -->
    <van-popup v-model:show="showAddPopup" position="bottom" round safe-area-inset-bottom :style="{ height: '70%' }">
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="showAddPopup = false">取消</span>
          <span class="title">快速记账</span>
          <span class="confirm" @click="handleSubmit">保存</span>
        </div>

        <van-tabs v-model:active="form.type" type="card" color="#1989fa" style="margin: 12px 16px;">
          <van-tab title="支出" :name="2" />
          <van-tab title="收入" :name="1" />
          <van-tab title="转账" :name="3" />
        </van-tabs>

        <van-cell-group inset>
          <van-field
            v-model="form.amount"
            type="number"
            label="金额 (¥)"
            placeholder="0.00"
            input-align="right"
            required
            label-width="5em"
          />

          <!-- 分类 (转账不选分类) -->
          <van-cell
            v-if="form.type !== 3"
            title="分类"
            is-link
            :value="selectedCategoryName || '请选择分类'"
            @click="showCategoryPicker = true"
            required
          />

          <!-- 账户 (支/收账户，或转出账户) -->
          <van-cell
            :title="form.type === 3 ? '转出账户' : '账户'"
            is-link
            :value="selectedAccountName || '请选择账户'"
            @click="showAccountPicker = true"
            required
          />

          <!-- 转入账户 (仅转账显示) -->
          <van-cell
            v-if="form.type === 3"
            title="转入账户"
            is-link
            :value="selectedToAccountName || '请选择转入账户'"
            @click="showToAccountPicker = true"
            required
          />

          <!-- 日期 -->
          <van-cell
            title="记账日期"
            is-link
            :value="form.transactionDate"
            @click="showDatePicker = true"
          />

          <!-- 备注 -->
          <van-field
            v-model="form.remark"
            label="备注"
            placeholder="填写备注说明 (选填)"
            input-align="right"
            label-width="5em"
          />
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 分类选择器 -->
    <van-popup v-model:show="showCategoryPicker" position="bottom" round>
      <van-picker
        title="选择分类"
        :columns="categoryColumns"
        @confirm="onCategoryConfirm"
        @cancel="showCategoryPicker = false"
      />
    </van-popup>

    <!-- 账户选择器 -->
    <van-popup v-model:show="showAccountPicker" position="bottom" round>
      <van-picker
        title="选择账户"
        :columns="accountColumns"
        @confirm="onAccountConfirm"
        @cancel="showAccountPicker = false"
      />
    </van-popup>

    <!-- 转入账户选择器 -->
    <van-popup v-model:show="showToAccountPicker" position="bottom" round>
      <van-picker
        title="选择转入账户"
        :columns="toAccountColumns"
        @confirm="onToAccountConfirm"
        @cancel="showToAccountPicker = false"
      />
    </van-popup>

    <!-- 日期选择器 -->
    <van-popup v-model:show="showDatePicker" position="bottom" round>
      <van-date-picker
        title="选择记账日期"
        v-model="currentDateArray"
        @confirm="onDateConfirm"
        @cancel="showDatePicker = false"
      />
    </van-popup>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import { showToast, showConfirmDialog } from 'vant';
import { transactionService, accountService, categoryService } from '../services';

const refreshing = ref(false);
const transactions = ref<any[]>([]);
const accounts = ref<any[]>([]);
const categories = ref<any[]>([]);

// 弹出层控制
const showAddPopup = ref(false);
const showCategoryPicker = ref(false);
const showAccountPicker = ref(false);
const showToAccountPicker = ref(false);
const showDatePicker = ref(false);

const todayStr = new Date().toISOString().split('T')[0];
const currentDateArray = ref<string[]>(todayStr.split('-'));

const form = ref<any>({
  type: 2,
  amount: '',
  categoryId: null,
  accountId: null,
  toAccountId: null,
  transactionDate: todayStr,
  remark: ''
});

const getCategoryName = (id: number) => {
  const c = categories.value.find((item: any) => item.id === id);
  return c ? c.name : (id ? '未知分类' : '无分类');
};

const getAccountName = (id: number) => {
  const a = accounts.value.find((item: any) => item.id === id);
  return a ? a.name : '未知账户';
};

const selectedCategoryName = computed(() => {
  return getCategoryName(form.value.categoryId);
});

const selectedAccountName = computed(() => {
  return form.value.accountId ? getAccountName(form.value.accountId) : '';
});

const selectedToAccountName = computed(() => {
  return form.value.toAccountId ? getAccountName(form.value.toAccountId) : '';
});

const categoryColumns = computed(() => {
  return categories.value
    .filter((c: any) => c.type === form.value.type && c.isActive === 1)
    .map((c: any) => ({ text: c.name, value: c.id }));
});

const accountColumns = computed(() => {
  return accounts.value.map((a: any) => ({
    text: `${a.name} (¥${a.currentBalance})`,
    value: a.id
  }));
});

const toAccountColumns = computed(() => {
  return accounts.value
    .filter((a: any) => a.id !== form.value.accountId)
    .map((a: any) => ({
      text: `${a.name} (¥${a.currentBalance})`,
      value: a.id
    }));
});

const formatNum = (val: any) => {
  return Number(val || 0).toFixed(2);
};

const getAmountClass = (type: number) => {
  if (type === 1) return 'income';
  if (type === 2) return 'expense';
  return 'transfer';
};

const getAmountPrefix = (type: number) => {
  if (type === 1) return '+';
  if (type === 2) return '-';
  return '';
};

const fetchData = async () => {
  try {
    const [txs, accs, cats] = await Promise.all([
      transactionService.getAllTransactions(),
      accountService.getAccounts(),
      categoryService.getCategories()
    ]);
    transactions.value = txs || [];
    accounts.value = accs || [];
    categories.value = cats || [];
  } catch (e) {
  } finally {
    refreshing.value = false;
  }
};

const openAddPopup = () => {
  form.value = {
    type: 2,
    amount: '',
    categoryId: categoryColumns.value.length > 0 ? categoryColumns.value[0].value : null,
    accountId: accounts.value.length > 0 ? accounts.value[0].id : null,
    toAccountId: null,
    transactionDate: todayStr,
    remark: ''
  };
  showAddPopup.value = true;
};

const onCategoryConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    form.value.categoryId = selectedOptions[0].value;
  }
  showCategoryPicker.value = false;
};

const onAccountConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    form.value.accountId = selectedOptions[0].value;
  }
  showAccountPicker.value = false;
};

const onToAccountConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    form.value.toAccountId = selectedOptions[0].value;
  }
  showToAccountPicker.value = false;
};

const onDateConfirm = ({ selectedValues }: any) => {
  form.value.transactionDate = selectedValues.join('-');
  showDatePicker.value = false;
};

const handleSubmit = async () => {
  if (!form.value.amount || Number(form.value.amount) <= 0) {
    showToast('请输入有效金额');
    return;
  }
  if (!form.value.accountId) {
    showToast('请选择账户');
    return;
  }
  if (form.value.type === 3 && !form.value.toAccountId) {
    showToast('请选择转入账户');
    return;
  }

  try {
    await transactionService.addTransaction({
      type: form.value.type,
      amount: Number(form.value.amount),
      transactionDate: form.value.transactionDate,
      categoryId: form.value.type === 3 ? null : form.value.categoryId,
      accountId: form.value.accountId,
      toAccountId: form.value.type === 3 ? form.value.toAccountId : null,
      remark: form.value.remark
    });
    showToast({ type: 'success', message: '记账成功' });
    showAddPopup.value = false;
    fetchData();
  } catch (e) {}
};

const handleDelete = (id: number) => {
  showConfirmDialog({
    title: '确认删除',
    message: '删除此笔流水将同时自动回滚账户余额，确定删除吗？'
  }).then(async () => {
    try {
      await transactionService.deleteTransaction(id);
      showToast({ type: 'success', message: '已删除' });
      fetchData();
    } catch (e) {}
  });
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.transactions-page {
  padding-bottom: 70px;
}

.tx-list {
  background: #fff;
}

.tx-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f2f3f5;
  background: #fff;
}

.tx-left {
  display: flex;
  flex-direction: column;
}

.tx-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.tx-cat {
  font-size: 15px;
  font-weight: 500;
  color: #323233;
}

.tx-remark {
  font-size: 12px;
  color: #969799;
}

.tx-meta {
  font-size: 12px;
  color: #969799;
  display: flex;
  gap: 4px;
}

.tx-right {
  font-size: 17px;
  font-weight: 600;
}

.tx-right.expense {
  color: #323233;
}

.tx-right.income {
  color: #07c160;
}

.tx-right.transfer {
  color: #1989fa;
}

.delete-btn {
  height: 100%;
}

.fab-btn {
  position: fixed;
  right: 20px;
  bottom: 80px;
  width: 52px;
  height: 52px;
  background: #1989fa;
  border-radius: 50%;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 14px rgba(25, 137, 250, 0.4);
  z-index: 99;
  cursor: pointer;
}

.popup-box {
  padding-bottom: 24px;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f2f3f5;
}

.popup-header .title {
  font-weight: 600;
  font-size: 16px;
}

.popup-header .cancel {
  color: #969799;
  font-size: 14px;
}

.popup-header .confirm {
  color: #1989fa;
  font-weight: 500;
  font-size: 14px;
}
</style>
