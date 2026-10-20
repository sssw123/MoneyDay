<template>
  <div class="business-page">
    <!-- 顶部数据汇总 -->
    <a-row :gutter="[16, 16]" style="margin-bottom: 24px;">
      <a-col :xs="24" :md="12" :xl="8">
        <a-card title="未结清总负债 (待还总额)">
          <h2 style="color: #C94747; margin-bottom: 4px;">¥{{ totalRemainingLiabilities }}</h2>
          <div style="font-size: 13px; color: #999;">锁定未来现金流流出</div>
        </a-card>
      </a-col>
      <a-col :xs="24" :md="12" :xl="8">
        <a-card title="还款中分期笔数">
          <h2 style="color: #1890ff; margin-bottom: 4px;">{{ activeCount }} 笔</h2>
          <div style="font-size: 13px; color: #999;">按月履约中消费分期</div>
        </a-card>
      </a-col>
      <a-col :xs="24" :md="12" :xl="8">
        <a-card title="本月应还分期总额">
          <h2 style="color: #fa8c16; margin-bottom: 4px;">¥{{ monthlyDueTotal }}</h2>
          <div style="font-size: 13px; color: #999;">已自动纳入周期固定支出</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 操作工具栏 -->
    <div class="page-toolbar">
      <a-space wrap>
        <a-button type="primary" @click="showAddModal">录入新分期</a-button>
        <span style="font-size: 13px; color: #666; margin-left: 8px;">
          (花呗、白条、信用卡分期及大件消费分期；到达还款日系统自动扣款记账)
        </span>
      </a-space>
    </div>

    <!-- 分期负债列表 -->
    <a-table :scroll="{ x: 'max-content' }" :dataSource="liabilities" :columns="columns" rowKey="id">
      <template #bodyCell="{ column, record }">
        <template v-if="column.key === 'status'">
          <a-tag :color="record.status === 'SETTLED' ? 'green' : 'blue'">
            {{ record.status === 'SETTLED' ? '已结清' : '还款中' }}
          </a-tag>
        </template>
        <template v-else-if="column.key === 'principal'">
          ¥{{ record.principal }}
        </template>
        <template v-else-if="column.key === 'remainingAmount'">
          <span :style="{ color: record.status === 'SETTLED' ? '#999' : '#C94747', fontWeight: 'bold' }">
            ¥{{ record.remainingAmount }}
          </span>
        </template>
        <template v-else-if="column.key === 'progress'">
          <div style="min-width: 140px;">
            <div style="font-size: 12px; color: #888; margin-bottom: 2px;">
              已还 {{ record.currentPeriod }} / {{ record.totalPeriods }} 期 (剩余 {{ record.remainingPeriods }} 期)
            </div>
            <a-progress :percent="record.progressPercent"
                        :status="record.status === 'SETTLED' ? 'success' : 'active'" />
          </div>
        </template>
        <template v-else-if="column.key === 'periodAmount'">
          ¥{{ record.periodAmount }}
        </template>
        <template v-else-if="column.key === 'nextRepaymentDate'">
          <span v-if="record.status === 'SETTLED'" style="color: #999;">-</span>
          <span v-else style="color: #557344; font-weight: 500;">
            {{ record.nextRepaymentDate || '待排期' }}
          </span>
        </template>
        <template v-else-if="column.key === 'repaymentDay'">
          每月 {{ record.repaymentDay }} 日
        </template>
        <template v-else-if="column.key === 'defaultAccount'">
          {{ record.defaultAccountName || '未指定' }}
        </template>
        <template v-else-if="column.key === 'category'">
          <a-tag color="cyan">{{ record.categoryName || '分期还款' }}</a-tag>
        </template>
        <template v-else-if="column.key === 'action'">
          <a-space>
            <template v-if="record.status !== 'SETTLED'">
              <a-button type="primary" size="small" @click="showRepayModal(record)">
                还款
              </a-button>
              <a-button type="link" size="small" @click="editLiability(record)">编辑</a-button>
            </template>
            <a-popconfirm title="确定删除该分期吗？历史已生成的扣款流水将继续保留" @confirm="deleteLiability(record.id)">
              <a-button type="link" size="small" danger>删除</a-button>
            </a-popconfirm>
          </a-space>
        </template>
      </template>
    </a-table>

    <!-- 录入 / 编辑分期弹窗 -->
    <a-modal v-model:open="modalVisible" :title="editingId ? '编辑分期' : '录入消费分期'" width="640px" @ok="handleOk">
      <a-form :model="form" :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="分期名称" required>
          <a-input v-model:value="form.name" placeholder="如：iPhone 15 分期、花呗账单、美团月付" />
        </a-form-item>
        <a-form-item label="分期总额(本金)" required>
          <a-input-number v-model:value="form.principal" :min="0.01" :precision="2" style="width: 100%" @change="recalculateAmount" />
        </a-form-item>
        <a-form-item label="分期期数" required>
          <a-input-number v-model:value="form.totalPeriods" :min="1" :max="360" :precision="0" style="width: 100%" @change="recalculateAmount" />
        </a-form-item>
        <a-form-item label="利率模式" required>
          <a-radio-group v-model:value="form.rateType" @change="recalculateAmount">
            <a-radio value="NONE">免息分期 (0利息)</a-radio>
            <a-radio value="FEE">每期手续费率</a-radio>
            <a-radio value="APR">年化利率(等额本息)</a-radio>
          </a-radio-group>
        </a-form-item>
        <a-form-item v-if="form.rateType !== 'NONE'" :label="form.rateType === 'FEE' ? '每期费率 (%)' : '年化利率 (%)'" required>
          <a-input-number v-model:value="form.interestRate" :min="0" :precision="4" style="width: 100%" @change="recalculateAmount" />
        </a-form-item>
        <a-form-item label="每期应还金额" required help="系统公式已自动推算，支持手动修改校准以对齐实际账单">
          <a-input-number v-model:value="form.periodAmount" :min="0.01" :precision="2" style="width: 100%" />
        </a-form-item>
        <a-form-item label="每月还款日" required help="还款日到达时系统将自动生成支出流水并扣减账户">
          <a-input-number v-model:value="form.repaymentDay" :min="1" :max="31" :precision="0" addonAfter="日" style="width: 100%" />
        </a-form-item>
        <a-form-item label="默认扣款账户" required help="余额不足时系统自动降级从余额最多账户扣款">
          <a-select v-model:value="form.defaultAccountId" placeholder="请选择默认扣款账户">
            <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
              {{ acc.name }} (余额: ¥{{ acc.currentBalance }})
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="支出记账分类" required help="自动扣款生成的流水分类，可自选数码、服装等">
          <a-select v-model:value="form.categoryId" placeholder="请选择支出记账分类">
            <a-select-option v-for="cat in expenseCategories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="已还期数" help="中途补录已发生的分期可在此填写已还期数(默认为0)，系统不生成历史扣款流水">
          <a-input-number v-model:value="form.currentPeriod" :min="0" :max="form.totalPeriods" :precision="0" style="width: 100%" />
        </a-form-item>
        <a-form-item label="下期还款日" required help="到达该日期系统将自动扣款，提前还款后此日期自动顺延">
          <a-date-picker v-model:value="form.nextRepaymentDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
        <a-form-item label="首期起算日期" required>
          <a-date-picker v-model:value="form.startDate" valueFormat="YYYY-MM-DD" style="width: 100%" />
        </a-form-item>
      </a-form>
    </a-modal>

    <!-- 分期还款弹窗 (双模式: 提前还期 vs 提前结清) -->
    <a-modal v-model:open="repayVisible" title="分期还款" @ok="handleRepayModalOk">
      <div v-if="repayRecord" style="margin-bottom: 16px;">
        <div style="font-size: 14px; margin-bottom: 8px;">
          分期项目：<b>{{ repayRecord.name }}</b>
        </div>
        <div style="font-size: 13px; color: #666; margin-bottom: 4px;">
          总期数：{{ repayRecord.totalPeriods }} 期 | 已还：{{ repayRecord.currentPeriod }} 期 | <b>待还剩余：{{ repayRecord.remainingPeriods }} 期</b>
        </div>
        <div style="font-size: 13px; color: #557344;">
          下一次计划还款日：<b>{{ repayRecord.nextRepaymentDate || '待排期' }}</b>
        </div>
      </div>

      <a-tabs v-model:activeKey="repayTabKey">
        <a-tab-pane key="period" tab="提前还期">
          <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
            <a-form-item label="归还期数" required>
              <a-input-number v-model:value="repayPeriodsCount" :min="1" :max="repayRecord?.remainingPeriods || 1" :precision="0" addonAfter="期" style="width: 100%" @change="onRepayPeriodsChange" />
            </a-form-item>
            <a-form-item label="还款金额" required help="系统已自动按期数推算应还金额，支持手动微调">
              <a-input-number v-model:value="repayAmount" :min="0.01" :precision="2" style="width: 100%" />
            </a-form-item>
            <a-form-item label="扣款账户" required>
              <a-select v-model:value="repayAccountId" placeholder="请选择扣款账户">
                <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
                  {{ acc.name }} (余额: ¥{{ acc.currentBalance }})
                </a-select-option>
              </a-select>
            </a-form-item>
            <a-alert type="info" show-icon message="防重说明" :description="`提前还款后，下一次应还日期将自动顺延 ${repayPeriodsCount} 个月，本周期到达还款日时系统绝不重复扣款。`" style="margin-top: 12px;" />
          </a-form>
        </a-tab-pane>

        <a-tab-pane key="settle" tab="提前结清">
          <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
            <a-form-item label="结清金额" required help="预填剩余待还总额，支持修改（若金融机构免除剩余手续费）">
              <a-input-number v-model:value="settleAmount" :min="0.01" :precision="2" style="width: 100%" />
            </a-form-item>
            <a-form-item label="扣款账户" required>
              <a-select v-model:value="settleAccountId" placeholder="请选择扣款账户">
                <a-select-option v-for="acc in accounts" :key="acc.id" :value="acc.id">
                  {{ acc.name }} (余额: ¥{{ acc.currentBalance }})
                </a-select-option>
              </a-select>
            </a-form-item>
            <a-alert type="warning" show-icon message="结清提示" description="提前结清将一次性偿还剩余所有期数，该分期将立即变更为【已结清】状态，后续不再生成周期扣款。" style="margin-top: 12px;" />
          </a-form>
        </a-tab-pane>
      </a-tabs>
    </a-modal>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import { message } from 'ant-design-vue';
import request from '../utils/request';

const liabilities = ref<any[]>([]);
const accounts = ref<any[]>([]);
const expenseCategories = ref<any[]>([]);

const columns = [
  { title: '状态', key: 'status', width: 90 },
  { title: '分期名称', dataIndex: 'name', key: 'name' },
  { title: '本金', key: 'principal', align: 'right' as const },
  { title: '剩余待还', key: 'remainingAmount', align: 'right' as const },
  { title: '还款进度', key: 'progress', width: 220 },
  { title: '每期应还', key: 'periodAmount', align: 'right' as const },
  { title: '下期还款日', key: 'nextRepaymentDate', width: 120 },
  { title: '还款日', key: 'repaymentDay' },
  { title: '默认账户', key: 'defaultAccount' },
  { title: '记账分类', key: 'category' },
  { title: '操作', key: 'action' }
];

// 汇总计算
const totalRemainingLiabilities = computed(() => {
  return liabilities.value
    .filter(l => l.status === 'REPAYING')
    .reduce((sum, l) => sum + (Number(l.remainingAmount) || 0), 0)
    .toFixed(2);
});

const activeCount = computed(() => {
  return liabilities.value.filter(l => l.status === 'REPAYING').length;
});

const monthlyDueTotal = computed(() => {
  return liabilities.value
    .filter(l => l.status === 'REPAYING')
    .reduce((sum, l) => sum + (Number(l.periodAmount) || 0), 0)
    .toFixed(2);
});

// 计算下一次还款日默认值
const calculateDefaultNextRepaymentDate = (rDay: number) => {
  const today = new Date();
  const year = today.getFullYear();
  const month = today.getMonth(); // 0-indexed
  const day = today.getDate();

  let targetYear = year;
  let targetMonth = month;
  if (day >= rDay) {
    targetMonth += 1;
    if (targetMonth > 11) {
      targetMonth = 0;
      targetYear += 1;
    }
  }
  const maxDays = new Date(targetYear, targetMonth + 1, 0).getDate();
  const actualDay = Math.min(rDay, maxDays);
  const mStr = String(targetMonth + 1).padStart(2, '0');
  const dStr = String(actualDay).padStart(2, '0');
  return `${targetYear}-${mStr}-${dStr}`;
};

// 弹窗与表单
const modalVisible = ref(false);
const editingId = ref<number | null>(null);
const form = ref({
  name: '',
  principal: 0,
  totalAmount: 0,
  totalPeriods: 12,
  currentPeriod: 0,
  rateType: 'NONE',
  interestRate: 0,
  periodAmount: 0,
  repaymentDay: 10,
  nextRepaymentDate: '',
  defaultAccountId: null as number | null,
  categoryId: null as number | null,
  startDate: new Date().toISOString().split('T')[0]
});

// 分期还款 (双模式)
const repayVisible = ref(false);
const repayRecord = ref<any>(null);
const repayTabKey = ref('period');

// 提前还期
const repayPeriodsCount = ref(1);
const repayAmount = ref<number>(0);
const repayAccountId = ref<number | null>(null);

// 提前结清
const settleAmount = ref<number>(0);
const settleAccountId = ref<number | null>(null);

const fetchData = async () => {
  liabilities.value = await request.get('/liabilities');
  accounts.value = await request.get('/accounts');
  const allCategories: any[] = await request.get('/categories');
  expenseCategories.value = allCategories.filter(c => c.type === 2);
};

const recalculateAmount = () => {
  const p = Number(form.value.principal) || 0;
  const n = Number(form.value.totalPeriods) || 1;
  const rate = Number(form.value.interestRate) || 0;

  if (p <= 0 || n <= 0) return;

  let monthly = 0;
  let total = p;

  if (form.value.rateType === 'NONE') {
    monthly = Math.round((p / n) * 100) / 100;
    total = p;
  } else if (form.value.rateType === 'FEE') {
    // 手续费率模式：每期还本金/期数 + 本金 * 费率%
    const feePerMonth = p * (rate / 100);
    monthly = Math.round(((p / n) + feePerMonth) * 100) / 100;
    total = Math.round((monthly * n) * 100) / 100;
  } else if (form.value.rateType === 'APR') {
    // 年化等额本息模式
    const monthlyRate = (rate / 100) / 12;
    if (monthlyRate <= 0) {
      monthly = Math.round((p / n) * 100) / 100;
    } else {
      const pow = Math.pow(1 + monthlyRate, n);
      monthly = Math.round((p * monthlyRate * pow / (pow - 1)) * 100) / 100;
    }
    total = Math.round((monthly * n) * 100) / 100;
  }

  form.value.periodAmount = monthly;
  form.value.totalAmount = total;
};

const showAddModal = () => {
  editingId.value = null;
  const defaultRDay = 10;
  form.value = {
    name: '',
    principal: 0,
    totalAmount: 0,
    totalPeriods: 12,
    currentPeriod: 0,
    rateType: 'NONE',
    interestRate: 0,
    periodAmount: 0,
    repaymentDay: defaultRDay,
    nextRepaymentDate: calculateDefaultNextRepaymentDate(defaultRDay),
    defaultAccountId: accounts.value.length > 0 ? accounts.value[0].id : null,
    categoryId: expenseCategories.value.find(c => c.name === '分期还款')?.id || (expenseCategories.value.length > 0 ? expenseCategories.value[0].id : null),
    startDate: new Date().toISOString().split('T')[0]
  };
  modalVisible.value = true;
};

const editLiability = (record: any) => {
  editingId.value = record.id;
  form.value = {
    name: record.name,
    principal: record.principal,
    totalAmount: record.totalAmount,
    totalPeriods: record.totalPeriods,
    currentPeriod: record.currentPeriod || 0,
    rateType: record.rateType || 'NONE',
    interestRate: record.interestRate || 0,
    periodAmount: record.periodAmount,
    repaymentDay: record.repaymentDay || 10,
    nextRepaymentDate: record.nextRepaymentDate || calculateDefaultNextRepaymentDate(record.repaymentDay || 10),
    defaultAccountId: record.defaultAccountId,
    categoryId: record.categoryId,
    startDate: record.startDate
  };
  modalVisible.value = true;
};

const handleOk = async () => {
  if (!form.value.name || !form.value.principal || !form.value.periodAmount || !form.value.defaultAccountId) {
    message.error('请填写完整信息');
    return;
  }
  try {
    if (!form.value.totalAmount) {
      form.value.totalAmount = form.value.periodAmount * form.value.totalPeriods;
    }
    if (editingId.value) {
      await request.put(`/liabilities/${editingId.value}`, form.value);
    } else {
      await request.post('/liabilities', form.value);
    }
    message.success('保存成功');
    modalVisible.value = false;
    fetchData();
  } catch (e) {}
};

const deleteLiability = async (id: number) => {
  try {
    await request.delete(`/liabilities/${id}`);
    message.success('删除成功');
    fetchData();
  } catch (e) {}
};

const showRepayModal = (record: any) => {
  repayRecord.value = record;
  repayTabKey.value = 'period';
  repayPeriodsCount.value = 1;
  repayAmount.value = record.periodAmount || 0;
  repayAccountId.value = record.defaultAccountId || (accounts.value.length > 0 ? accounts.value[0].id : null);

  settleAmount.value = record.remainingAmount || 0;
  settleAccountId.value = record.defaultAccountId || (accounts.value.length > 0 ? accounts.value[0].id : null);

  repayVisible.value = true;
};

const onRepayPeriodsChange = () => {
  const pCount = repayPeriodsCount.value || 1;
  const pAmount = repayRecord.value?.periodAmount || 0;
  repayAmount.value = Math.round(pCount * pAmount * 100) / 100;
};

const handleRepayModalOk = async () => {
  if (repayTabKey.value === 'period') {
    if (!repayAccountId.value || !repayAmount.value || repayAmount.value <= 0) {
      message.error('请指定扣款账户和还款金额');
      return;
    }
    try {
      await request.post(`/liabilities/${repayRecord.value.id}/repay`, {
        accountId: repayAccountId.value,
        periods: repayPeriodsCount.value,
        amount: repayAmount.value
      });
      message.success(`提前归还 ${repayPeriodsCount.value} 期成功！已顺延下期还款日`);
      repayVisible.value = false;
      fetchData();
    } catch (e) {}
  } else {
    if (!settleAccountId.value || !settleAmount.value || settleAmount.value <= 0) {
      message.error('请指定扣款账户和结清金额');
      return;
    }
    try {
      await request.post(`/liabilities/${repayRecord.value.id}/settle`, {
        accountId: settleAccountId.value,
        settleAmount: settleAmount.value
      });
      message.success('分期提前结清成功！');
      repayVisible.value = false;
      fetchData();
    } catch (e) {}
  }
};

onMounted(() => {
  fetchData();
});
</script>
