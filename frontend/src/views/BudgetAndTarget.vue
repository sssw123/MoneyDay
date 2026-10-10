<template>
  <div>
    <a-tabs v-model:activeKey="activeKey">
      <a-tab-pane key="budget" tab="预算管理">
        <div style="margin-bottom: 16px;">
          <a-button type="primary" @click="showBudgetModal">设置预算</a-button>
        </div>
        <a-table :dataSource="budgets" :columns="budgetColumns" rowKey="id">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'action'">
              <a-space>
                <a @click="editBudget(record)">编辑</a>
                <a-popconfirm title="确定删除吗？" @confirm="deleteBudget(record.id)">
                  <a style="color: red">删除</a>
                </a-popconfirm>
              </a-space>
            </template>
          </template>
        </a-table>
      </a-tab-pane>

      <a-tab-pane key="target" tab="攒钱目标">
        <div style="margin-bottom: 16px;">
          <a-button type="primary" @click="showTargetModal">新增目标</a-button>
        </div>
        <a-table :dataSource="targets" :columns="targetColumns" rowKey="id">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'progress'">
              <a-progress :percent="Math.round((record.allocatedAmount / record.targetAmount) * 100)" />
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a @click="editTarget(record)">编辑</a>
                <a-popconfirm title="确定删除吗？" @confirm="deleteTarget(record.id)">
                  <a style="color: red">删除</a>
                </a-popconfirm>
              </a-space>
            </template>
          </template>
        </a-table>
      </a-tab-pane>
    </a-tabs>

    <a-modal v-model:open="budgetVisible" :title="budgetEditingId ? '编辑预算' : '设置预算'" @ok="handleBudgetOk">
      <a-form :model="budgetForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="预算金额" required>
          <a-input-number v-model:value="budgetForm.amount" :min="0" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="开始日期" required>
          <a-date-picker v-model:value="budgetForm.cycleStartDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
        <a-form-item label="结束日期" required>
          <a-date-picker v-model:value="budgetForm.cycleEndDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>

    <a-modal v-model:open="targetVisible" :title="targetEditingId ? '编辑目标' : '新增目标'" @ok="handleTargetOk">
      <a-form :model="targetForm" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="目标名称" required>
          <a-input v-model:value="targetForm.name" />
        </a-form-item>
        <a-form-item label="目标金额" required>
          <a-input-number v-model:value="targetForm.targetAmount" :min="0.01" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="已存金额">
          <a-input-number v-model:value="targetForm.allocatedAmount" :min="0" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="截止日期">
          <a-date-picker v-model:value="targetForm.deadline" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const activeKey = ref('budget');

const budgets = ref([]);
const targets = ref([]);

const budgetVisible = ref(false);
const budgetEditingId = ref<number | null>(null);
const budgetForm = ref({ amount: 0, cycleStartDate: '', cycleEndDate: '' });

const targetVisible = ref(false);
const targetEditingId = ref<number | null>(null);
const targetForm = ref({ name: '', targetAmount: 0, allocatedAmount: 0, deadline: '' });

const budgetColumns = [
  { title: '预算金额', dataIndex: 'amount', key: 'amount' },
  { title: '开始日期', dataIndex: 'cycleStartDate', key: 'cycleStartDate' },
  { title: '结束日期', dataIndex: 'cycleEndDate', key: 'cycleEndDate' },
  { title: '操作', key: 'action' }
];

const targetColumns = [
  { title: '目标名称', dataIndex: 'name', key: 'name' },
  { title: '目标金额', dataIndex: 'targetAmount', key: 'targetAmount' },
  { title: '已存金额', dataIndex: 'allocatedAmount', key: 'allocatedAmount' },
  { title: '进度', key: 'progress' },
  { title: '截止日期', dataIndex: 'deadline', key: 'deadline' },
  { title: '操作', key: 'action' }
];

const fetchData = async () => {
  budgets.value = await request.get('/budgets');
  targets.value = await request.get('/targets');
};

const showBudgetModal = () => {
  budgetEditingId.value = null;
  budgetForm.value = { amount: 0, cycleStartDate: '', cycleEndDate: '' };
  budgetVisible.value = true;
};

const editBudget = (record: any) => {
  budgetEditingId.value = record.id;
  budgetForm.value = { ...record };
  budgetVisible.value = true;
};

const handleBudgetOk = async () => {
  try {
    if (budgetEditingId.value) {
      await request.put(`/budgets/${budgetEditingId.value}`, budgetForm.value);
    } else {
      await request.post('/budgets', budgetForm.value);
    }
    message.success('保存成功');
    budgetVisible.value = false;
    fetchData();
  } catch (e) {}
};

const deleteBudget = async (id: number) => {
  try {
    await request.delete(`/budgets/${id}`);
    message.success('删除成功');
    fetchData();
  } catch (e) {}
};

const showTargetModal = () => {
  targetEditingId.value = null;
  targetForm.value = { name: '', targetAmount: 0, allocatedAmount: 0, deadline: '' };
  targetVisible.value = true;
};

const editTarget = (record: any) => {
  targetEditingId.value = record.id;
  targetForm.value = { ...record };
  targetVisible.value = true;
};

const handleTargetOk = async () => {
  try {
    if (targetEditingId.value) {
      await request.put(`/targets/${targetEditingId.value}`, targetForm.value);
    } else {
      await request.post('/targets', targetForm.value);
    }
    message.success('保存成功');
    targetVisible.value = false;
    fetchData();
  } catch (e) {}
};

const deleteTarget = async (id: number) => {
  try {
    await request.delete(`/targets/${id}`);
    message.success('删除成功');
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
