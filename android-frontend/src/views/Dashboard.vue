<template>
  <div class="dashboard-page">
    <van-nav-bar title="MoneyDay 财务看板" fixed placeholder>
      <template #right>
        <van-icon :name="showAmount ? 'eye-o' : 'closed-eye'" size="18" @click="showAmount = !showAmount" />
      </template>
    </van-nav-bar>

    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <div class="content-box">
        <!-- 资产总览卡片 -->
        <div class="asset-card">
          <div class="asset-header">
            <span class="label">可用净资产 (总资产 - 负债)</span>
          </div>
          <div class="asset-main-amount">
            {{ showAmount ? `¥${formatNum(stats.availableNetAssets)}` : '****' }}
          </div>
          <div class="asset-sub-grid">
            <div class="sub-item">
              <span class="sub-label">总资产</span>
              <span class="sub-value">{{ showAmount ? `¥${formatNum(stats.totalAssets)}` : '****' }}</span>
            </div>
            <div class="sub-item">
              <span class="sub-label">未还负债</span>
              <span class="sub-value danger">{{ showAmount ? `¥${formatNum(stats.totalLiabilityAmount)}` : '****' }}</span>
            </div>
            <div class="sub-item">
              <span class="sub-label">累计结余池</span>
              <span class="sub-value success">{{ showAmount ? `¥${formatNum(stats.cumulativeBalance)}` : '****' }}</span>
            </div>
          </div>
        </div>

        <!-- 本期周期状态卡片 -->
        <div class="card-section" v-if="currentCycle">
          <div class="section-title">
            <span>当前账单周期</span>
            <span class="cycle-dates">{{ currentCycle.cycleStartDate }} ~ {{ currentCycle.cycleEndDate }}</span>
          </div>
          <div class="cycle-summary-grid">
            <div class="cycle-summary-item">
              <span class="num text-success">+¥{{ formatNum(currentCycle.income) }}</span>
              <span class="txt">周期总收入</span>
            </div>
            <div class="cycle-summary-item">
              <span class="num text-danger">-¥{{ formatNum(currentCycle.expense) }}</span>
              <span class="txt">周期总支出</span>
            </div>
            <div class="cycle-summary-item">
              <span class="num" :class="currentCycle.balance >= 0 ? 'text-success' : 'text-danger'">
                {{ currentCycle.balance >= 0 ? '+' : '' }}¥{{ formatNum(currentCycle.balance) }}
              </span>
              <span class="txt">周期结余</span>
            </div>
          </div>
        </div>

        <!-- 透支分期到期速览 -->
        <div class="card-section" v-if="repayingLiabilities.length > 0">
          <div class="section-title">
            <span>待还分期 ({{ repayingLiabilities.length }})</span>
            <span class="more-link" @click="$router.push('/plan')">全部 ></span>
          </div>
          <div class="liability-item" v-for="l in repayingLiabilities.slice(0, 3)" :key="l.id">
            <div class="liability-row">
              <span class="l-name">{{ l.name }}</span>
              <span class="l-amount">¥{{ l.periodAmount }}/期</span>
            </div>
            <div class="liability-progress">
              <van-progress :percentage="calcProgress(l.currentPeriod, l.totalPeriods)" stroke-width="4" color="#ee0a24" :show-pivot="false" />
            </div>
            <div class="liability-sub">
              <span>已还 {{ l.currentPeriod }}/{{ l.totalPeriods }} 期</span>
              <span class="due-date">下期：{{ l.nextRepaymentDate || '待排期' }}</span>
            </div>
          </div>
        </div>

        <!-- 心愿单速览 -->
        <div class="card-section" v-if="unfulfilledWishlists.length > 0">
          <div class="section-title">
            <span>心愿清单</span>
            <span class="more-link" @click="$router.push('/plan')">全部 ></span>
          </div>
          <div class="wishlist-item" v-for="w in unfulfilledWishlists.slice(0, 3)" :key="w.id">
            <div class="wishlist-row">
              <span class="w-name">{{ w.name }}</span>
              <span class="w-target">目标 ¥{{ w.targetAmount }}</span>
            </div>
            <div class="wishlist-progress">
              <van-progress :percentage="w.progress || 0" stroke-width="4" color="#07c160" :show-pivot="false" />
            </div>
            <div class="wishlist-sub">
              <span>已攒进度 {{ w.progress || 0 }}%</span>
              <span class="due-date">{{ w.estimatedCompletionDate || '计算中' }}</span>
            </div>
          </div>
        </div>
      </div>
    </van-pull-refresh>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import request from '../utils/request';

const showAmount = ref(true);
const refreshing = ref(false);

const stats = ref<any>({
  totalAssets: 0,
  totalLiabilityAmount: 0,
  availableNetAssets: 0,
  cumulativeBalance: 0
});

const cycles = ref<any[]>([]);
const liabilities = ref<any[]>([]);
const wishlists = ref<any[]>([]);

const currentCycle = computed(() => {
  return cycles.value.length > 0 ? cycles.value[0] : null;
});

const repayingLiabilities = computed(() => {
  return liabilities.value.filter((l: any) => l.status === 'REPAYING');
});

const unfulfilledWishlists = computed(() => {
  return wishlists.value.filter((w: any) => w.isRealized === 0);
});

const formatNum = (val: any) => {
  if (val === undefined || val === null) return '0.00';
  return Number(val).toFixed(2);
};

const calcProgress = (cur: number, total: number) => {
  if (!total) return 0;
  return Math.min(100, Math.round((cur / total) * 100));
};

const fetchData = async () => {
  try {
    const [s, c, l, w] = await Promise.all([
      request.get('/stats/dashboard'),
      request.get('/cycles'),
      request.get('/liabilities'),
      request.get('/wishlist')
    ]);
    stats.value = s || {};
    cycles.value = c || [];
    liabilities.value = l || [];
    wishlists.value = w || [];
  } catch (e) {
  } finally {
    refreshing.value = false;
  }
};

const onRefresh = () => {
  fetchData();
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.dashboard-page {
  padding-bottom: 20px;
}

.content-box {
  padding: 12px 16px;
}

.asset-card {
  background: linear-gradient(135deg, #1989fa 0%, #39a9ed 100%);
  border-radius: 14px;
  padding: 20px 18px;
  color: #fff;
  box-shadow: 0 4px 12px rgba(25, 137, 250, 0.25);
  margin-bottom: 16px;
}

.asset-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 13px;
  opacity: 0.9;
}

.asset-main-amount {
  font-size: 32px;
  font-weight: bold;
  letter-spacing: -0.5px;
  margin: 12px 0 16px 0;
}

.asset-sub-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  border-top: 1px solid rgba(255, 255, 255, 0.2);
  padding-top: 14px;
  gap: 8px;
}

.sub-item {
  display: flex;
  flex-direction: column;
}

.sub-label {
  font-size: 11.5px;
  opacity: 0.85;
  margin-bottom: 3px;
}

.sub-value {
  font-size: 15px;
  font-weight: 600;
}

.sub-value.danger {
  color: #ffeef0;
}

.sub-value.success {
  color: #eaffea;
}

.card-section {
  background: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  margin-bottom: 14px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.03);
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 14.5px;
  font-weight: 600;
  color: #323233;
  margin-bottom: 12px;
}

.cycle-dates {
  font-size: 12px;
  color: #969799;
  font-weight: normal;
}

.more-link {
  font-size: 12px;
  color: #1989fa;
  font-weight: normal;
}

.cycle-summary-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  text-align: center;
  gap: 8px;
}

.cycle-summary-item {
  display: flex;
  flex-direction: column;
}

.cycle-summary-item .num {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 4px;
}

.cycle-summary-item .txt {
  font-size: 11px;
  color: #969799;
}

.text-success { color: #07c160; }
.text-danger { color: #ee0a24; }

.liability-item, .wishlist-item {
  padding: 10px 0;
  border-bottom: 1px solid #f2f3f5;
}
.liability-item:last-child, .wishlist-item:last-child {
  border-bottom: none;
  padding-bottom: 2px;
}

.liability-row, .wishlist-row {
  display: flex;
  justify-content: space-between;
  font-size: 14px;
  font-weight: 500;
  margin-bottom: 6px;
}

.liability-progress, .wishlist-progress {
  margin-bottom: 6px;
}

.liability-sub, .wishlist-sub {
  display: flex;
  justify-content: space-between;
  font-size: 11.5px;
  color: #969799;
}

.due-date {
  color: #7232dd;
}
</style>
