<template>
  <div class="business-page">
    <div class="page-toolbar">
      <h3 style="margin: 0; font-weight: 600;">账单周期预算表</h3>
      <div style="color: #888; font-size: 13px;">
        打破自然月限制 · 固存强制储蓄 · 固收/固支自动联动
      </div>
    </div>

    <a-table :scroll="{ x: 'max-content' }" :dataSource="cycles" :columns="cycleColumns" rowKey="id" :pagination="false">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'period'">
          {{ record.cycleStartDate }} 至 {{ record.cycleEndDate }}
        </template>
        <template v-else-if="column.key === 'fixedItems'">
          <a-space wrap>
            <template v-for="item in record.fixedItems || []" :key="item.id">
              <a-tag v-if="item.type === 'DEPOSIT'" color="green">
                {{ item.name }}: ¥{{ item.amount }}
              </a-tag>
              <a-tag v-else :color="item.isBooked ? 'default' : (item.type === 'INCOME' ? 'blue' : 'red')"
                     :style="{ cursor: 'pointer' }"
                     @click="handleTagClick(record, item)">
                {{ item.name }}{{ item.categoryName ? ' · ' + item.categoryName : '' }}: ¥{{ item.amount }}
                <span v-if="!item.isBooked"> (点此{{ item.type === 'INCOME' ? '到账' : '支付' }})</span>
                <span v-else style="color: #999;"> (已完成 - 点击撤销)</span>
              </a-tag>
            </template>
          </a-space>
        </template>
        <template v-else-if="column.key === 'balance'">
          <span :style="{ color: record.balance >= 0 ? 'var(--positive)' : 'var(--negative)', fontWeight: 'bold' }">
            ¥{{ record.balance }}
          </span>
        </template>
        <template v-else-if="column.key === 'income' || column.key === 'expense'">
          ¥{{ record[column.dataIndex] }}
        </template>
      </template>
    </a-table>

    <!-- 记账弹窗 -->
    <a-modal v-model:open="itemVisible" :title="itemModalTitle" @ok="handleItemOk">
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item :label="itemAmountLabel" required>
          <a-input-number v-model:value="itemAmount" :min="0" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item :label="itemAccountLabel" required>
          <a-select v-model:value="itemAccountId" placeholder="请选择账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item :label="itemDateLabel" required>
          <a-date-picker v-model:value="itemDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message, Modal } from 'ant-design-vue';
import request from '../utils/request';

const cycles = ref([]);
const accounts = ref<any[]>([]);

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '固定项目', key: 'fixedItems' },
  { title: '总收入', dataIndex: 'income', key: 'income', align: 'right' as const },
  { title: '总支出', dataIndex: 'expense', key: 'expense', align: 'right' as const },
  { title: '周期结余', key: 'balance', align: 'right' as const }
];

// 项目记账相关
const itemVisible = ref(false);
const itemModalTitle = ref('');
const itemAmountLabel = ref('');
const itemAccountLabel = ref('');
const itemDateLabel = ref('');

const itemCycleId = ref<number | null>(null);
const itemTargetId = ref<string>('');
const itemAmount = ref<number>(0);
const itemAccountId = ref<number | null>(null);
const itemDate = ref<string>('');

const fetchData = async () => {
  try {
    cycles.value = await request.get('/cycles');
    accounts.value = await request.get('/accounts');
  } catch { /* Shared request handling covers errors and discarded prior-user responses. */ }
};

const handleTagClick = (record: any, item: any) => {
  if (!item.isBooked) {
    showItemModal(record, item);
  } else {
    Modal.confirm({
      title: '撤销已完成状态',
      content: `确定要撤销「${item.name}」的完成状态吗？若关联了记账流水，系统将自动撤销该笔流水并回退账户余额。`,
      okText: '确认撤销',
      cancelText: '取消',
      onOk: async () => {
        try {
          await request.post(`/cycles/${record.id}/unbook-item/${item.id}`);
          message.success('已成功撤销完成状态');
          fetchData();
        } catch (e) {}
      }
    });
  }
};

const showItemModal = (record: any, item: any) => {
  itemCycleId.value = record.id;
  itemTargetId.value = item.id;
  itemAmount.value = item.amount || 0;
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
  itemVisible.value = true;
};

const handleItemOk = async () => {
  if (!itemAccountId.value || !itemDate.value) {
    message.error('请填写完整信息');
    return;
  }
  try {
    await request.post(`/cycles/${itemCycleId.value}/book-item/${itemTargetId.value}`, {
      amount: itemAmount.value,
      accountId: itemAccountId.value,
      date: itemDate.value
    });
    message.success('记账成功');
    itemVisible.value = false;
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
