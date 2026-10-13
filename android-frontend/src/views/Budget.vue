<template>
  <div class="budget-page">
    <van-nav-bar title="账单周期预算表" fixed placeholder />

    <van-pull-refresh v-model="refreshing" @refresh="fetchData">
      <div class="content-box">
        <div v-if="cycles.length === 0" style="padding: 60px 0; text-align: center;">
          <van-empty description="暂无账单周期数据" />
        </div>

        <div v-else class="cycle-list">
          <div class="cycle-card" v-for="c in cycles" :key="c.id">
            <div class="cycle-header">
              <span class="cycle-period">{{ c.cycleStartDate }} 至 {{ c.cycleEndDate }}</span>
              <span class="cycle-balance" :class="c.balance >= 0 ? 'text-success' : 'text-danger'">
                结余: ¥{{ formatNum(c.balance) }}
              </span>
            </div>

            <div class="cycle-stats-row">
              <div class="stat-col">
                <span class="label">总收入</span>
                <span class="val text-success">+¥{{ formatNum(c.income) }}</span>
              </div>
              <div class="stat-col">
                <span class="label">总支出</span>
                <span class="val text-danger">-¥{{ formatNum(c.expense) }}</span>
              </div>
            </div>

            <!-- 固定项目列表 -->
            <div class="items-wrap" v-if="c.fixedItems && c.fixedItems.length > 0">
              <div class="items-title">固定项目 (点击到账/扣款)</div>
              <div class="tags-container">
                <template v-for="item in c.fixedItems" :key="item.id">
                  <!-- 固存 -->
                  <van-tag v-if="item.type === 'DEPOSIT'" type="success" size="medium">
                    {{ item.name }}: ¥{{ item.amount }}
                  </van-tag>
                  <!-- 固收/固支 -->
                  <van-tag
                    v-else
                    :type="item.isBooked ? 'default' : (item.type === 'INCOME' ? 'primary' : 'danger')"
                    size="medium"
                    class="clickable-tag"
                    @click="handleTagClick(c, item)"
                  >
                    {{ item.name }}: ¥{{ item.amount }}
                    <span v-if="!item.isBooked"> (点此{{ item.type === 'INCOME' ? '到账' : '支付' }})</span>
                    <span v-else> (已完成)</span>
                  </van-tag>
                </template>
              </div>
            </div>
          </div>
        </div>
      </div>
    </van-pull-refresh>

    <!-- 记账操作弹窗 -->
    <van-popup v-model:show="itemVisible" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="itemVisible = false">取消</span>
          <span class="title">{{ itemModalTitle }}</span>
          <span class="confirm" @click="handleItemOk">确认</span>
        </div>

        <van-cell-group inset style="margin-top: 12px;">
          <van-field
            v-model="itemAmount"
            type="number"
            :label="itemAmountLabel"
            placeholder="0.00"
            input-align="right"
            required
            label-width="5em"
          />

          <van-cell
            :title="itemAccountLabel"
            is-link
            :value="selectedAccountName || '请选择账户'"
            @click="showAccountPicker = true"
            required
          />

          <van-cell
            :title="itemDateLabel"
            is-link
            :value="itemDate"
            @click="showDatePicker = true"
          />
        </van-cell-group>
      </div>
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
import request from '../utils/request';

const refreshing = ref(false);
const cycles = ref<any[]>([]);
const accounts = ref<any[]>([]);

// 项目记账弹窗
const itemVisible = ref(false);
const itemModalTitle = ref('');
const itemAmountLabel = ref('');
const itemAccountLabel = ref('');
const itemDateLabel = ref('');

const itemCycleId = ref<number | null>(null);
const itemTargetId = ref<string>('');
const itemAmount = ref<string>('');
const itemAccountId = ref<number | null>(null);
const itemDate = ref<string>('');

const showAccountPicker = ref(false);
const showDatePicker = ref(false);
const currentDateArray = ref<string[]>([]);

const formatNum = (val: any) => {
  return Number(val || 0).toFixed(2);
};

const getAccountName = (id: number) => {
  const a = accounts.value.find((acc: any) => acc.id === id);
  return a ? a.name : '';
};

const selectedAccountName = computed(() => {
  return itemAccountId.value ? getAccountName(itemAccountId.value) : '';
});

const accountColumns = computed(() => {
  return accounts.value.map((a: any) => ({
    text: `${a.name} (¥${a.currentBalance})`,
    value: a.id
  }));
});

const fetchData = async () => {
  try {
    const [c, a] = await Promise.all([
      request.get('/cycles'),
      request.get('/accounts')
    ]);
    cycles.value = c || [];
    accounts.value = a || [];
  } catch (e) {
  } finally {
    refreshing.value = false;
  }
};

const handleTagClick = (record: any, item: any) => {
  if (!item.isBooked) {
    showItemModal(record, item);
  } else {
    showConfirmDialog({
      title: '撤销已完成状态',
      message: `确定要撤销「${item.name}」的完成状态吗？关联的流水将自动删除并回退账户余额。`
    }).then(async () => {
      try {
        await request.post(`/cycles/${record.id}/unbook-item/${item.id}`);
        showToast({ type: 'success', message: '已撤销' });
        fetchData();
      } catch (e) {}
    });
  }
};

const showItemModal = (record: any, item: any) => {
  itemCycleId.value = record.id;
  itemTargetId.value = item.id;
  itemAmount.value = String(item.amount || '');
  itemAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;

  if (item.type === 'INCOME') {
    itemModalTitle.value = '确认固收到账';
    itemAmountLabel.value = '到账金额';
    itemAccountLabel.value = '入账账户';
    itemDateLabel.value = '入账日期';
  } else {
    itemModalTitle.value = '确认固支扣款';
    itemAmountLabel.value = '支付金额';
    itemAccountLabel.value = '扣款账户';
    itemDateLabel.value = '支付日期';
  }

  const today = new Date().toISOString().split('T')[0];
  if (today >= record.cycleStartDate && today <= record.cycleEndDate) {
    itemDate.value = today;
  } else {
    itemDate.value = record.cycleStartDate;
  }
  currentDateArray.value = itemDate.value.split('-');
  itemVisible.value = true;
};

const onAccountConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    itemAccountId.value = selectedOptions[0].value;
  }
  showAccountPicker.value = false;
};

const onDateConfirm = ({ selectedValues }: any) => {
  itemDate.value = selectedValues.join('-');
  showDatePicker.value = false;
};

const handleItemOk = async () => {
  if (!itemAccountId.value || !itemDate.value || !itemAmount.value) {
    showToast('请填写完整信息');
    return;
  }
  try {
    await request.post(`/cycles/${itemCycleId.value}/book-item/${itemTargetId.value}`, {
      amount: Number(itemAmount.value),
      accountId: itemAccountId.value,
      date: itemDate.value
    });
    showToast({ type: 'success', message: '记账成功' });
    itemVisible.value = false;
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.budget-page {
  padding-bottom: 20px;
}

.content-box {
  padding: 12px 16px;
}

.cycle-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.cycle-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
}

.cycle-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f2f3f5;
  padding-bottom: 10px;
  margin-bottom: 12px;
}

.cycle-period {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
}

.cycle-balance {
  font-size: 14px;
  font-weight: bold;
}

.cycle-stats-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  margin-bottom: 12px;
}

.stat-col {
  display: flex;
  flex-direction: column;
}

.stat-col .label {
  font-size: 11.5px;
  color: #969799;
  margin-bottom: 2px;
}

.stat-col .val {
  font-size: 15px;
  font-weight: 600;
}

.items-wrap {
  border-top: 1px dashed #ebedf0;
  padding-top: 10px;
}

.items-title {
  font-size: 11.5px;
  color: #969799;
  margin-bottom: 8px;
}

.tags-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.clickable-tag {
  cursor: pointer;
}

.text-success { color: #07c160; }
.text-danger { color: #ee0a24; }

.popup-box {
  padding-bottom: 20px;
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
