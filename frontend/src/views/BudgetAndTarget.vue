<template>
  <div>
    <a-tabs v-model:activeKey="activeKey">
      <a-tab-pane key="cycle" tab="周期表">
        <a-table :dataSource="cycles" :columns="cycleColumns" rowKey="id" :pagination="false">
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
                    {{ item.name }}: ¥{{ item.amount }}
                    <span v-if="!item.isBooked"> (点此{{ item.type === 'INCOME' ? '到账' : '支付' }})</span>
                    <span v-else style="color: #999;"> (已完成 - 点击撤销)</span>
                  </a-tag>
                </template>
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
import { message, Modal } from 'ant-design-vue';
import request from '../utils/request';

const activeKey = ref('cycle');

const cycles = ref([]);
const targets = ref([]);
const accounts = ref<any[]>([]);

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '固定项目', key: 'fixedItems' },
  { title: '总收入', dataIndex: 'income', key: 'income' },
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
