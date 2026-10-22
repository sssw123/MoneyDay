<template>
  <div class="dashboard">
    <div class="dashboard-welcome">
      <div>
        <div class="eyebrow">{{ todayLabel }}</div>
        <h1>{{ greeting }}，让积累发生。</h1>
        <p>照顾好今天的每一笔，也离想要的生活近一点。</p>
      </div>
      <a-button type="primary" @click="router.push('/transactions')"
        ><template #icon><SwapOutlined /></template>查看账单<ArrowRightOutlined
      /></a-button>
    </div>
    <section class="asset-overview" aria-label="全局资产概览">
      <a-card class="net-assets-card" :bordered="false">
        <div class="asset-card-top">
          <span>可用净资产</span><span class="asset-icon"><WalletOutlined /></span>
        </div>
        <div class="net-assets-value money" :class="{ negative: stats.availableAssets < 0 }">
          <span>¥</span>{{ formatMoney(stats.availableAssets) }}
        </div>
        <div class="asset-caption">每一个长期目标，都有真实的底气。</div>
        <div class="net-assets-breakdown">
          <div>
            <span>总资产</span><strong class="money">¥{{ formatMoney(stats.totalAssets) }}</strong>
          </div>
          <span class="formula-minus">−</span>
          <div>
            <span>未还负债</span
            ><strong class="money">¥{{ formatMoney(stats.totalLiabilities || 0) }}</strong>
          </div>
        </div>
        <div class="asset-card-bottom">
          <span class="soft-pill">总资产 − 未还负债</span
          ><router-link to="/accounts">查看账户 <ArrowRightOutlined /></router-link>
        </div>
      </a-card>
      <div class="asset-support-grid">
        <a-card class="asset-support-card"
          ><div class="asset-card-top"><span>总资产</span><BankOutlined /></div>
          <strong class="metric-value money">¥{{ formatMoney(stats.totalAssets) }}</strong>
          <p>所有账户活期与储蓄余额</p></a-card
        >
        <a-card class="asset-support-card"
          ><div class="asset-card-top"><span>未还总负债</span><CreditCardOutlined /></div>
          <strong class="metric-value money" :class="{ negative: stats.totalLiabilities > 0 }"
            >¥{{ formatMoney(stats.totalLiabilities || 0) }}</strong
          >
          <p>分期待还 · 未来的刚性支出</p></a-card
        >
        <a-card class="asset-support-card balance-pool-card"
          ><div>
            <div class="asset-card-top"><span>全局累计结余池</span><RiseOutlined /></div>
            <strong
              class="metric-value money"
              :class="stats.cumulativeBalance >= 0 ? 'positive' : 'negative'"
              >¥{{ formatMoney(stats.cumulativeBalance) }}</strong
            >
            <p>日常的点滴结余，让心愿慢慢靠近。</p>
          </div>
          <router-link to="/plan/wishlist" class="round-link" aria-label="查看心愿单"
            ><ArrowRightOutlined /></router-link
        ></a-card>
      </div>
    </section>
    <a-card class="cycle-summary">
      <template #title
        ><div class="section-title">
          <div>
            <h2>本周期 · 财务透视</h2>
            <p>固存 + 结余 / 超支 = 最终结余</p>
          </div>
          <router-link to="/budget" class="section-link"
            >查看预算 <ArrowRightOutlined
          /></router-link></div
      ></template>
      <div class="cycle-metrics">
        <div>
          <span class="metric-label">本期固存 <small>计划必攒</small></span
          ><strong class="money">¥{{ formatMoney(stats.currentFixedDeposit || 0) }}</strong>
          <p>先存一笔，为未来留底。</p>
        </div>
        <div>
          <span class="metric-label">本期结余 / 超支</span
          ><strong class="money" :class="stats.currentBalance >= 0 ? 'positive' : 'negative'"
            >{{ stats.currentBalance >= 0 ? '+¥' : '−¥'
            }}{{ formatMoney(Math.abs(stats.currentBalance)) }}</strong
          >
          <p>
            {{ stats.currentBalance >= 0 ? '日常消费有结余，心愿再近一步。' : '本期日常开销超支，请留意支出。' }}
          </p>
        </div>
        <div>
          <span class="metric-label">最终结余 <small>净沉淀</small></span
          ><strong class="money" :class="stats.currentFinalBalance >= 0 ? 'positive' : 'negative'"
            >{{ stats.currentFinalBalance >= 0 ? '¥' : '−¥'
            }}{{ formatMoney(Math.abs(stats.currentFinalBalance)) }}</strong
          >
          <p>固存与日常结余，共同推进目标。</p>
        </div>
      </div>
    </a-card>
    <!-- 第三行：分类支出饼图 与 历史周期透视列表 -->
    <a-row :gutter="[20, 20]">
      <a-col :xs="24" :xl="10">
        <a-card title="本周期分类支出占比">
          <v-chart
            v-if="hasCategoryExpenses"
            class="expense-chart"
            :option="pieOption"
            autoresize
          />
          <div v-else class="chart-empty">
            <div class="empty-donut" aria-hidden="true"></div>
            <strong>还没有分类支出</strong>
            <p>记下第一笔支出后，来看看钱花在了哪里。</p>
            <router-link to="/transactions">开始记录 <ArrowRightOutlined /></router-link>
          </div>
        </a-card>
      </a-col>
      <a-col :xs="24" :xl="14">
        <a-card title="各周期结余/超支透视表">
          <a-table
            :scroll="{ x: 'max-content' }"
            :dataSource="cycles"
            :columns="cycleColumns"
            rowKey="id"
            :pagination="false"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'period'">
                {{ record.cycleStartDate }} ~ {{ record.cycleEndDate }}
              </template>
              <template v-else-if="column.key === 'fixedDeposit'">
                ¥{{ getCycleDeposit(record) }}
              </template>
              <template v-else-if="column.key === 'balance'">
                <span
                  :style="{ color: record.balance >= 0 ? '#477824' : '#C94747', fontWeight: 'bold' }"
                >
                  {{ record.balance >= 0 ? '+¥' + record.balance : '-¥' + Math.abs(record.balance) }}
                </span>
              </template>
              <template v-else-if="column.key === 'finalBalance'">
                <span
                  :style="{ color: (getCycleDeposit(record) + record.balance) >= 0 ? '#477824' : '#C94747', fontWeight: 'bold' }"
                >
                  ¥{{ (getCycleDeposit(record) + record.balance).toFixed(2) }}
                </span>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>

    <!-- 第四行：目标快捷实现 与 心愿单快捷兑现 -->
    <a-row :gutter="[20, 20]" style="margin-top: 20px">
      <a-col :xs="24" :xl="12">
        <a-card title="目标快捷实现">
          <a-table
            :scroll="{ x: 'max-content' }"
            :dataSource="targets"
            :columns="longTermColumns"
            rowKey="id"
            :pagination="false"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'targetAmount'"> ¥{{ record.targetAmount }} </template>
              <template v-else-if="column.key === 'progress'">
                <a-progress
                  :percent="record.progress || 0"
                  :stroke-color="record.isRealized === 1 ? '#477824' : '#557344'"
                  :status="(record.progress || 0) >= 100 ? 'success' : 'active'"
                />
              </template>
              <template v-else-if="column.key === 'estimatedCompletionDate'">
                <span v-if="record.isRealized === 1">-</span>
                <a-tag v-else-if="record.estimatedCompletionDate === '当前可实现'" color="green">
                  当前可实现
                </a-tag>
                <a-tooltip
                  v-else-if="record.estimatedCompletionDate === '无法预估'"
                  :title="record.estimatedReason || '存钱速度无盈余，无法预估'"
                >
                  <a-tag color="default">无法预估</a-tag>
                </a-tooltip>
                <a-tooltip v-else-if="record.isEstimatedFallback" :title="record.estimatedReason">
                  <a-tag color="orange" style="cursor: pointer">
                    {{ record.estimatedCompletionDate }} ⚠
                  </a-tag>
                </a-tooltip>
                <a-tooltip v-else :title="record.estimatedReason">
                  <span style="color: #557344; font-weight: 500">
                    {{ record.estimatedCompletionDate }}
                  </span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space v-if="record.isRealized === 1">
                  <a-tag color="green">已实现</a-tag>
                  <a-popconfirm
                    title="确定撤销该目标的实现状态吗？扣款流水将被删除并退回账户余额"
                    @confirm="handleUnrealizeTarget(record)"
                  >
                    <a-button type="link" size="small" style="color: #c94747; font-size: 12px"
                      >撤销</a-button
                    >
                  </a-popconfirm>
                </a-space>
                <template v-else>
                  <a-tooltip
                    :title="stats.availableAssets < record.targetAmount ? `可用净资产不足以实现此目标 (缺口: ¥${record.gap || 0})` : ''"
                  >
                    <a-button
                      type="primary"
                      size="small"
                      :disabled="stats.availableAssets < record.targetAmount"
                      @click="showRealizeModal(record, 'TARGET')"
                    >
                      实现目标
                    </a-button>
                  </a-tooltip>
                </template>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>

      <a-col :xs="24" :xl="12">
        <a-card title="心愿单快捷兑现">
          <a-table
            :scroll="{ x: 'max-content' }"
            :dataSource="wishlists"
            :columns="wishlistColumns"
            rowKey="id"
            :pagination="false"
            size="small"
          >
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'targetAmount'"> ¥{{ record.targetAmount }} </template>
              <template v-else-if="column.key === 'progress'">
                <a-progress
                  :percent="record.progress || 0"
                  :stroke-color="record.isRealized === 1 ? '#477824' : '#A36678'"
                  :status="(record.progress || 0) >= 100 ? 'success' : 'active'"
                />
              </template>
              <template v-else-if="column.key === 'estimatedCompletionDate'">
                <span v-if="record.isRealized === 1">-</span>
                <a-tag v-else-if="record.estimatedCompletionDate === '当前可实现'" color="green">
                  当前可实现
                </a-tag>
                <a-tooltip
                  v-else-if="record.estimatedCompletionDate === '无法预估'"
                  :title="record.estimatedReason || '存钱速度无盈余，无法预估'"
                >
                  <a-tag color="default">无法预估</a-tag>
                </a-tooltip>
                <a-tooltip v-else-if="record.isEstimatedFallback" :title="record.estimatedReason">
                  <a-tag color="orange" style="cursor: pointer">
                    {{ record.estimatedCompletionDate }} ⚠
                  </a-tag>
                </a-tooltip>
                <a-tooltip v-else :title="record.estimatedReason">
                  <span style="color: #a36678; font-weight: 500">
                    {{ record.estimatedCompletionDate }}
                  </span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space v-if="record.isRealized === 1">
                  <a-tag color="green">已兑现</a-tag>
                  <a-popconfirm
                    title="确定撤销该心愿的兑现状态吗？扣款流水将被删除并退回账户余额"
                    @confirm="handleUnrealizeWishlist(record)"
                  >
                    <a-button type="link" size="small" style="color: #c94747; font-size: 12px"
                      >撤销</a-button
                    >
                  </a-popconfirm>
                </a-space>
                <template v-else>
                  <a-tooltip
                    :title="stats.cumulativeBalance < record.targetAmount ? `当前累计结余不足 (¥${stats.cumulativeBalance})，点击可任性兑现` : ''"
                  >
                    <a-button
                      type="primary"
                      size="small"
                      :style="stats.cumulativeBalance < record.targetAmount ? { background: '#A36678', borderColor: '#A36678' } : {}"
                      @click="showRealizeModal(record, 'WISHLIST')"
                    >
                      兑现心愿
                    </a-button>
                  </a-tooltip>
                </template>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>

    <!-- 实现目标 / 心愿弹窗 -->
    <a-modal
      v-model:open="realizeVisible"
      :title="realizeKind === 'TARGET' ? '实现目标（扣款设定）' : '兑现心愿（扣款设定）'"
      @ok="handleRealizeOk"
    >
      <div
        v-if="realizeKind === 'WISHLIST' && stats.cumulativeBalance < (realizeItem?.targetAmount || 0)"
        style="margin-bottom: 16px"
      >
        <a-alert
          type="warning"
          show-icon
          message="结余超支软警告"
          :description="`当前全局累计结余为 ¥${stats.cumulativeBalance}，小于心愿金额 ¥${realizeItem?.targetAmount}。兑现此心愿将导致结余超支或动用老本储蓄。兑现心愿完全看心情，确定要任性实现吗？`"
        />
      </div>
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item
          label="扣款账户"
          required
          :help="realizeKind === 'TARGET' ? '实现目标将生成一笔真实支出记录，分类自动绑定为【目标】' : '兑现心愿将生成一笔真实支出记录，分类自动绑定为【目标】'"
        >
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
import { ref, onMounted, computed } from 'vue';
import {
  SwapOutlined,
  ArrowRightOutlined,
  WalletOutlined,
  BankOutlined,
  CreditCardOutlined,
  RiseOutlined,
} from '@ant-design/icons-vue';
import { message } from 'ant-design-vue';
import { useRouter } from 'vue-router';
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { PieChart } from 'echarts/charts';
import { TitleComponent, TooltipComponent, LegendComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import request from '../utils/request';

use([CanvasRenderer, PieChart, TitleComponent, TooltipComponent, LegendComponent]);

const router = useRouter();
const todayLabel = new Intl.DateTimeFormat('zh-CN', {
  year: 'numeric',
  month: 'long',
  day: 'numeric',
  weekday: 'long',
}).format(new Date());
const hour = new Date().getHours();
const greeting = hour < 12 ? '上午好' : hour < 18 ? '下午好' : '晚上好';
const formatMoney = (value: number) =>
  Number(value || 0).toLocaleString('zh-CN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
const stats = ref({
  totalAssets: 0,
  totalLiabilities: 0,
  availableAssets: 0,
  cumulativeBalance: 0,
  currentIncome: 0,
  currentExpense: 0,
  currentFixedDeposit: 0,
  currentBalance: 0,
  currentFinalBalance: 0,
  categoryExpenses: [],
});

const cycles = ref<any[]>([]);
const targets = ref<any[]>([]);
const wishlists = ref<any[]>([]);
const accounts = ref<any[]>([]);

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '固存', key: 'fixedDeposit', align: 'right' as const },
  { title: '本期结余/超支', key: 'balance', align: 'right' as const },
  { title: '最终结余 (固存+结余)', key: 'finalBalance', align: 'right' as const },
];

const longTermColumns = [
  { title: '目标名称', dataIndex: 'name', key: 'name' },
  { title: '目标金额', key: 'targetAmount', align: 'right' as const },
  { title: '净资产进度', key: 'progress' },
  { title: '预计实现时间', key: 'estimatedCompletionDate' },
  { title: '操作', key: 'action' },
];

const wishlistColumns = [
  { title: '心愿名称', dataIndex: 'name', key: 'name' },
  { title: '心愿金额', key: 'targetAmount', align: 'right' as const },
  { title: '结余进度', key: 'progress' },
  { title: '预计达成时间', key: 'estimatedCompletionDate' },
  { title: '操作', key: 'action' },
];

const getCycleDeposit = (record: any) => {
  if (!record.fixedItems) return 0;
  return record.fixedItems.reduce((acc: number, item: any) => {
    return item.type === 'DEPOSIT' ? acc + (Number(item.amount) || 0) : acc;
  }, 0);
};

// 快捷实现 / 兑现
const realizeVisible = ref(false);
const realizeKind = ref<'TARGET' | 'WISHLIST'>('TARGET');
const realizeItem = ref<any>(null);
const realizeAccountId = ref<number | null>(null);

const showRealizeModal = (record: any, kind: 'TARGET' | 'WISHLIST') => {
  realizeItem.value = record;
  realizeKind.value = kind;
  realizeAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!realizeAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    if (realizeKind.value === 'TARGET') {
      await request.post(`/targets/${realizeItem.value.id}/realize`, {
        accountId: realizeAccountId.value,
      });
      message.success('目标实现成功！账户已扣款');
    } else {
      await request.post(`/wishlists/${realizeItem.value.id}/realize`, {
        accountId: realizeAccountId.value,
      });
      message.success('心愿兑现成功！账户已扣款');
    }
    realizeVisible.value = false;
    refreshData();
  } catch (e) {}
};

const handleUnrealizeTarget = async (record: any) => {
  try {
    await request.post(`/targets/${record.id}/unrealize`);
    message.success('已成功撤销目标实现状态，资金已退回账户！');
    refreshData();
  } catch (e) {}
};

const handleUnrealizeWishlist = async (record: any) => {
  try {
    await request.post(`/wishlists/${record.id}/unrealize`);
    message.success('已成功撤销心愿兑现状态，资金已退回账户！');
    refreshData();
  } catch (e) {}
};

const hasCategoryExpenses = computed(() =>
  stats.value.categoryExpenses.some((item: { value: number }) => Number(item.value) > 0),
);
const pieOption = computed(() => ({
  color: ['#A4CC7B', '#3F5743', '#9CB4A1', '#C7AC7F', '#8DA4BA', '#CAB5CE'],
  tooltip: {
    trigger: 'item',
    borderWidth: 0,
    backgroundColor: '#fff',
    textStyle: { color: '#171B18' },
  },
  legend: {
    bottom: 0,
    left: 'center',
    icon: 'circle',
    itemWidth: 8,
    itemHeight: 8,
    textStyle: { color: '#667068', fontSize: 12 },
  },
  series: [
    {
      name: '分类支出',
      type: 'pie',
      radius: ['50%', '72%'],
      center: ['50%', '44%'],
      avoidLabelOverlap: true,
      label: { show: false },
      itemStyle: { borderRadius: 5, borderColor: '#fff', borderWidth: 4 },
      data: stats.value.categoryExpenses,
      emphasis: { scaleSize: 5, label: { show: true, fontSize: 14, fontWeight: 600 } },
    },
  ],
}));

const refreshData = async () => {
  try {
    stats.value = await request.get('/stats');
    cycles.value = await request.get('/cycles');
    targets.value = await request.get('/targets');
    wishlists.value = await request.get('/wishlists');
    accounts.value = await request.get('/accounts');
  } catch { /* Shared request handling covers errors and discarded prior-user responses. */ }
};

onMounted(() => {
  refreshData();
});
</script>

<style scoped>
.dashboard-welcome {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
  margin-bottom: 28px;
}
.dashboard-welcome h1 {
  font-size: clamp(25px, 2.5vw, 34px);
  line-height: 1.4;
  font-weight: 600;
  letter-spacing: -0.9px;
  margin-bottom: 10px;
}
.dashboard-welcome p {
  color: var(--muted);
  font-size: 13px;
  margin: 0;
}
.dashboard-welcome .ant-btn {
  height: 44px;
  padding-inline: 20px;
}
.asset-overview {
  display: grid;
  grid-template-columns: 1.1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}
.net-assets-card {
  background: radial-gradient(ellipse at 0 0, #d2eeae 0, #edf6e2 48%, #f9fcf5 100%);
  border: 1px solid #e2ecd7;
}
.net-assets-card :deep(.ant-card-body) {
  padding: 28px 30px;
}
.asset-card-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  color: #5b6b52;
  font-weight: 500;
}
.asset-icon {
  width: 32px;
  height: 32px;
  display: grid;
  place-items: center;
  background: #ffffff60;
  border-radius: 10px;
}
.net-assets-value {
  font-size: clamp(32px, 4vw, 62px);
  font-weight: 500;
  letter-spacing: -2.5px;
  margin: 24px 0 6px;
  line-height: 1.15;
  overflow-wrap: anywhere;
}
.net-assets-value > span {
  font-size: 28px;
  margin-right: 7px;
}
.asset-caption {
  font-size: 12px;
  color: #66765d;
}
.net-assets-breakdown {
  display: flex;
  align-items: center;
  gap: 22px;
  padding: 22px 0;
  margin-top: 18px;
  border-top: 1px solid #cad9bb80;
}
.net-assets-breakdown div {
  min-width: 0;
}
.net-assets-breakdown div > span {
  font-size: 11px;
  color: #66765d;
  display: block;
  margin-bottom: 6px;
}
.net-assets-breakdown strong {
  font-size: 17px;
  font-weight: 500;
  overflow-wrap: anywhere;
}
.formula-minus {
  color: #829474;
}
.asset-card-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 11px;
}
.asset-card-bottom a,
.section-link {
  color: #4c613c;
  font-size: 12px;
}
.soft-pill {
  padding: 5px 10px;
  background: #dfeecf;
  border-radius: 20px;
  color: #4d6738;
}
.asset-support-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}
.asset-support-card :deep(.ant-card-body) {
  padding: 24px;
}
.asset-support-card .asset-card-top {
  color: var(--muted);
}
.metric-value {
  display: block;
  font-size: clamp(21px, 2.2vw, 32px);
  font-weight: 500;
  letter-spacing: -1px;
  margin: 20px 0 9px;
  line-height: 1.3;
  overflow-wrap: anywhere;
}
.asset-support-card p {
  color: var(--muted);
  font-size: 11px;
  margin: 0;
}
.balance-pool-card {
  grid-column: 1 / -1;
}
.balance-pool-card :deep(.ant-card-body) {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}
.balance-pool-card :deep(.ant-card-body) > div {
  flex: 1;
  min-width: 0;
}
.balance-pool-card .metric-value {
  margin-top: 14px;
}
.round-link {
  width: 38px;
  height: 38px;
  background: #f1f6eb;
  border: 1px solid #dfe8d8;
  border-radius: 50%;
  display: grid;
  place-items: center;
  color: #4f6741;
  flex-shrink: 0;
}
.cycle-summary {
  margin-bottom: 20px;
}
.cycle-metrics {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
}
.cycle-metrics > div {
  padding: 0 24px;
  border-left: 1px solid var(--line);
  min-width: 0;
}
.cycle-metrics > div:first-child {
  padding-left: 0;
  border: 0;
}
.metric-label {
  display: block;
  font-size: 12px;
  color: var(--muted);
}
.metric-label small {
  font-size: 10px;
  color: #7b8676;
  margin-left: 5px;
}
.cycle-metrics strong {
  display: block;
  font-size: clamp(22px, 2vw, 30px);
  font-weight: 500;
  letter-spacing: -0.7px;
  margin: 12px 0 6px;
  overflow-wrap: anywhere;
}
.cycle-metrics p {
  font-size: 11px;
  color: var(--muted);
  margin: 0;
}
.expense-chart {
  height: 300px;
}
.chart-empty {
  min-height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
}
.empty-donut {
  border: 20px solid #eef3e8;
  width: 108px;
  height: 108px;
  border-radius: 50%;
  margin-bottom: 22px;
}
.chart-empty strong {
  font-weight: 500;
  font-size: 13px;
}
.chart-empty p {
  color: var(--muted);
  font-size: 12px;
  margin: 8px 0 12px;
}
.chart-empty a {
  font-size: 12px;
}
@media (max-width: 1199px) {
  .asset-overview {
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }
  .asset-support-grid {
    gap: 12px;
  }
  .asset-support-card :deep(.ant-card-body) {
    padding: 20px 16px;
  }
  .net-assets-card :deep(.ant-card-body) {
    padding: 24px;
  }
  .net-assets-breakdown {
    gap: 12px;
  }
  .cycle-metrics > div {
    padding-inline: 16px;
  }
}
@media (max-width: 767px) {
  .dashboard-welcome {
    flex-direction: column;
    align-items: flex-start;
  }
  .dashboard-welcome h1 {
    font-size: 26px;
  }
  .asset-overview {
    grid-template-columns: 1fr;
  }
  .asset-support-grid {
    grid-template-columns: 1fr;
  }
  .balance-pool-card {
    grid-column: auto;
  }
  .net-assets-value {
    font-size: 44px;
  }
  .cycle-metrics {
    grid-template-columns: 1fr;
    gap: 22px;
  }
  .cycle-metrics > div {
    padding: 20px 0 0;
    border-left: 0;
    border-top: 1px solid var(--line);
  }
  .cycle-metrics > div:first-child {
    padding-top: 0;
  }
  .cycle-metrics strong {
    font-size: 28px;
  }
  .section-title {
    align-items: flex-start;
  }
  .section-link {
    white-space: nowrap;
  }
}
</style>
