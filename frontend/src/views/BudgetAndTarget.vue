<template>
  <div>
    <a-tabs v-model:activeKey="activeKey">
      <a-tab-pane key="cycle" tab="周期表">
        <a-table :dataSource="cycles" :columns="cycleColumns" rowKey="id" :pagination="false">
          <template #bodyCell="{ column, record }">
            <template v-if="column.key === 'period'">
              {{ record.cycleStartDate }} 至 {{ record.cycleEndDate }}
            </template>
            <template v-else-if="column.key === 'fixedDeposit'">
              <a-space>
                ¥{{ record.fixedDeposit }}
                <a @click="editFixedDeposit(record)" style="font-size: 12px; margin-left: 8px;">修改</a>
              </a-space>
            </template>
            <template v-else-if="column.key === 'balance'">
              <span :style="{ color: record.balance >= 0 ? 'green' : 'red', fontWeight: 'bold' }">
                ¥{{ record.balance }}
              </span>
            </template>
            <template v-else-if="column.key === 'income' || column.key === 'expense'">
              ¥{{ record[column.dataIndex] }}
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
            <template v-else-if="column.key === 'isRealized'">
              <a-tag :color="record.isRealized === 1 ? 'green' : 'blue'">
                {{ record.isRealized === 1 ? '已实现' : '进行中' }}
              </a-tag>
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a-button type="primary" size="small" v-if="record.isRealized === 0" @click="showRealizeModal(record)">实现目标</a-button>
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

    <a-modal v-model:open="fdVisible" title="修改本期固存" @ok="handleFdOk">
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="固存金额" required>
          <a-input-number v-model:value="fdAmount" :min="0" :precision="2" style="width: 100%" />
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

    <a-modal v-model:open="realizeVisible" title="实现目标（扣款设定）" @ok="handleRealizeOk">
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required help="实现目标将生成一笔真实支出记录">
          <a-select v-model:value="realizeAccountId" placeholder="请选择扣款账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (余额: ¥{{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>
      </a-form>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const activeKey = ref('cycle');

const cycles = ref([]);
const targets = ref([]);
const accounts = ref<any[]>([]);

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '总收入', dataIndex: 'income', key: 'income' },
  { title: '固存 (必攒)', key: 'fixedDeposit' },
  { title: '总支出', dataIndex: 'expense', key: 'expense' },
  { title: '周期结余', key: 'balance' }
];

const targetColumns = [
  { title: '状态', key: 'isRealized' },
  { title: '目标名称', dataIndex: 'name', key: 'name' },
  { title: '目标金额', dataIndex: 'targetAmount', key: 'targetAmount' },
  { title: '已存金额', dataIndex: 'allocatedAmount', key: 'allocatedAmount' },
  { title: '进度', key: 'progress' },
  { title: '截止日期', dataIndex: 'deadline', key: 'deadline' },
  { title: '操作', key: 'action' }
];

// 固存修改相关
const fdVisible = ref(false);
const fdEditingId = ref<number | null>(null);
const fdAmount = ref<number>(0);

// 目标相关
const targetVisible = ref(false);
const targetEditingId = ref<number | null>(null);
const targetForm = ref({ name: '', targetAmount: 0, allocatedAmount: 0, deadline: '' });

// 目标实现相关
const realizeVisible = ref(false);
const realizeTargetId = ref<number | null>(null);
const realizeAccountId = ref<number | null>(null);

const fetchData = async () => {
  cycles.value = await request.get('/cycles');
  targets.value = await request.get('/targets');
  accounts.value = await request.get('/accounts');
};

const editFixedDeposit = (record: any) => {
  fdEditingId.value = record.id;
  fdAmount.value = record.fixedDeposit;
  fdVisible.value = true;
};

const handleFdOk = async () => {
  if (fdEditingId.value) {
    try {
      await request.put(`/cycles/${fdEditingId.value}/fixed-deposit`, { fixedDeposit: fdAmount.value });
      message.success('修改成功');
      fdVisible.value = false;
      fetchData();
    } catch (e) {}
  }
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

const showRealizeModal = (record: any) => {
  realizeTargetId.value = record.id;
  realizeAccountId.value = null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!realizeAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/targets/${realizeTargetId.value}/realize`, { accountId: realizeAccountId.value });
    message.success('目标实现成功！账户已扣款');
    realizeVisible.value = false;
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>
