<template>
  <div class="business-page">
    <div class="page-toolbar">
      <a-button type="primary" @click="showModal">记一笔</a-button>
    </div>
    
    <a-table :scroll="{ x: 'max-content' }" :dataSource="transactions" :columns="columns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'type'">
          <a-tag :color="getTypeColor(record.type)">
            {{ getTypeName(record.type) }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'amount'">
          <span :style="{ color: record.type === 2 ? 'var(--negative)' : (record.type === 1 ? 'var(--positive)' : '#48759A') }">
            {{ record.type === 2 ? '-' : (record.type === 1 ? '+' : '') }}{{ record.amount }}
          </span>
        </template>
        <template v-else-if="column.key === 'account'">
          {{ getAccountName(record.accountId) }}
          <span v-if="record.type === 3"> -> {{ getAccountName(record.toAccountId) }}</span>
        </template>
        <template v-else-if="column.key === 'category'">
          {{ getCategoryName(record.categoryId) }}
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <a-button type="link" size="small" @click="editTransaction(record)">编辑</a-button>
            <a-popconfirm title="确定删除这笔流水吗？余额将会自动恢复" @confirm="deleteTransaction(record.id)">
              <a-button type="link" size="small" danger>删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="visible" :title="editingId ? '编辑流水' : '记一笔'" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="类型" required>
          <a-radio-group v-model:value="formState.type">
            <a-radio :value="2">支出</a-radio>
            <a-radio :value="1">收入</a-radio>
            <a-radio :value="3">转账</a-radio>
          </a-radio-group>
        </a-form-item>

        <a-form-item label="金额" required>
          <a-input-number v-model:value="formState.amount" :min="0.01" :precision="2" style="width: 100%" />
        </a-form-item>

        <a-form-item label="日期" required>
          <a-date-picker v-model:value="formState.transactionDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>

        <a-form-item :label="formState.type === 3 ? '转出账户' : '账户'" required>
          <a-select v-model:value="formState.accountId">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (余额: {{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="转入账户" required v-if="formState.type === 3">
          <a-select v-model:value="formState.toAccountId">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (余额: {{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="分类" required v-if="formState.type !== 3">
          <a-select v-model:value="formState.categoryId">
            <a-select-option v-for="c in categories.filter(c => c.type === formState.type && c.isActive === 1)" :key="c.id" :value="c.id">
              {{ c.name }}
            </a-select-option>
          </a-select>
        </a-form-item>

        <a-form-item label="备注">
          <a-input v-model:value="formState.remark" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';
import dayjs from 'dayjs';

const transactions = ref([]);
const accounts = ref<any[]>([]);
const categories = ref<any[]>([]);
const visible = ref(false);
const editingId = ref<number | null>(null);

const formState = ref({
  type: 2,
  amount: 0,
  transactionDate: dayjs().format('YYYY-MM-DD'),
  accountId: null,
  toAccountId: null,
  categoryId: null,
  remark: ''
});

const columns = [
  { title: '日期', dataIndex: 'transactionDate', key: 'date' },
  { title: '类型', key: 'type' },
  { title: '分类', key: 'category' },
  { title: '账户', key: 'account' },
  { title: '金额', key: 'amount', align: 'right' as const },
  { title: '备注', dataIndex: 'remark', key: 'remark' },
  { title: '操作', key: 'action' }
];

const fetchData = async () => {
  accounts.value = await request.get('/accounts');
  categories.value = await request.get('/categories');
  transactions.value = await request.get('/transactions');
};

const getAccountName = (id: number) => {
  const acc = accounts.value.find(a => a.id === id);
  return acc ? acc.name : '-';
};

const getCategoryName = (id: number) => {
  if (!id) return '-';
  const c = categories.value.find(c => c.id === id);
  return c ? c.name : '-';
};

const getTypeName = (type: number) => {
  return type === 1 ? '收入' : type === 2 ? '支出' : '转账';
};
const getTypeColor = (type: number) => {
  return type === 1 ? 'green' : type === 2 ? 'red' : 'blue';
};

const showModal = () => {
  editingId.value = null;
  formState.value = {
    type: 2,
    amount: 0,
    transactionDate: dayjs().format('YYYY-MM-DD'),
    accountId: accounts.value.length ? accounts.value[0].id : null,
    toAccountId: null,
    categoryId: null,
    remark: ''
  };
  visible.value = true;
};

const editTransaction = (record: any) => {
  editingId.value = record.id;
  formState.value = { ...record };
  visible.value = true;
};

const handleOk = async () => {
  if (!formState.value.amount || !formState.value.accountId) {
    message.error('请填写完整信息');
    return;
  }
  if (formState.value.type !== 3 && !formState.value.categoryId) {
    message.error('请选择分类');
    return;
  }
  if (formState.value.type === 3 && !formState.value.toAccountId) {
    message.error('请选择转入账户');
    return;
  }
  try {
    if (editingId.value) {
      await request.put(`/transactions/${editingId.value}`, formState.value);
      message.success('更新成功');
    } else {
      await request.post('/transactions', formState.value);
      message.success('记账成功');
    }
    visible.value = false;
    fetchData(); // reload all to update balances
  } catch (e) {
  }
};

const deleteTransaction = async (id: number) => {
  try {
    await request.delete(`/transactions/${id}`);
    message.success('删除成功，余额已恢复');
    fetchData();
  } catch (e) {
  }
};

onMounted(() => {
  fetchData();
});
</script>
