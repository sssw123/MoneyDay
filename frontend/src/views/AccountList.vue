<template>
  <div>
    <div style="margin-bottom: 16px;">
      <a-button type="primary" @click="showModal">新增账户</a-button>
    </div>
    
    <a-table :dataSource="accounts" :columns="columns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'action'">
          <a-space>
            <a @click="editAccount(record)">编辑</a>
            <a-popconfirm title="确定删除吗？" @confirm="deleteAccount(record.id)">
              <a style="color: red">删除</a>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <a-modal v-model:open="visible" :title="editingId ? '编辑账户' : '新增账户'" @ok="handleOk">
      <a-form :model="formState" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="账户名称" required>
          <a-input v-model:value="formState.name" />
        </a-form-item>
        <a-form-item label="账户类型" required>
          <a-select v-model:value="formState.type">
            <a-select-option value="CASH">现金</a-select-option>
            <a-select-option value="BANK">银行卡</a-select-option>
            <a-select-option value="EWALLET">电子钱包</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="期初余额" v-if="!editingId">
          <a-input-number v-model:value="formState.initialBalance" :min="0" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="当前余额" v-if="editingId">
          <a-input-number v-model:value="formState.currentBalance" :precision="2" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const accounts = ref([]);
const visible = ref(false);
const editingId = ref<number | null>(null);

const formState = ref({
  name: '',
  type: 'CASH',
  initialBalance: 0,
  currentBalance: 0
});

const columns = [
  { title: '账户名称', dataIndex: 'name', key: 'name' },
  { title: '类型', dataIndex: 'type', key: 'type' },
  { title: '当前余额', dataIndex: 'currentBalance', key: 'currentBalance' },
  { title: '操作', key: 'action' }
];

const fetchAccounts = async () => {
  accounts.value = await request.get('/accounts');
};

const showModal = () => {
  editingId.value = null;
  formState.value = { name: '', type: 'CASH', initialBalance: 0, currentBalance: 0 };
  visible.value = true;
};

const editAccount = (record: any) => {
  editingId.value = record.id;
  formState.value = { ...record };
  visible.value = true;
};

const handleOk = async () => {
  try {
    if (editingId.value) {
      await request.put(`/accounts/${editingId.value}`, formState.value);
      message.success('更新成功');
    } else {
      await request.post('/accounts', formState.value);
      message.success('添加成功');
    }
    visible.value = false;
    fetchAccounts();
  } catch (e) {
    // error handled in interceptor
  }
};

const deleteAccount = async (id: number) => {
  try {
    await request.delete(`/accounts/${id}`);
    message.success('删除成功');
    fetchAccounts();
  } catch (e) {
  }
};

onMounted(() => {
  fetchAccounts();
});
</script>
