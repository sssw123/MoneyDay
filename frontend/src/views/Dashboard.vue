<template>
  <div style="padding: 24px;">
    <!-- 第一行：全局资产与收支概览 -->
    <a-row :gutter="16" style="margin-bottom: 24px;">
      <a-col :span="6">
        <a-card title="总资产 (可用净资产)">
          <h2 style="margin-bottom: 4px;">¥{{ stats.totalAssets }}</h2>
          <div style="font-size: 13px; color: #666;">
            长期资产目标托底池
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="全局累计结余池">
          <h2 style="margin-bottom: 4px;" :style="{ color: stats.cumulativeBalance >= 0 ? '#52c41a' : '#ff4d4f' }">
            ¥{{ stats.cumulativeBalance }}
          </h2>
          <div style="font-size: 13px; color: #666;">
            心愿单达成标尺池 (随时任性兑现)
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="本周期收入">
          <h2 style="color: #52c41a; margin-bottom: 4px;">+¥{{ stats.currentIncome }}</h2>
          <div style="font-size: 13px; color: #999;">真实入账流水</div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="本周期支出">
          <h2 style="color: #ff4d4f; margin-bottom: 4px;">-¥{{ stats.currentExpense }}</h2>
          <div style="font-size: 13px; color: #999;">真实开销流水</div>
        </a-card>
      </a-col>
    </a-row>

    <!-- 第二行：本周期深度财务透视 (固存 + 结余 = 最终结余) -->
    <a-card title="本周期财务透视（固存 + 结余/超支 = 最终结余）" style="margin-bottom: 24px;">
      <a-row :gutter="24" style="text-align: center;">
        <a-col :span="8">
          <div style="padding: 12px; background: #fafafa; border-radius: 8px;">
            <div style="color: #666; font-size: 14px; margin-bottom: 8px;">本期固存 (计划必攒)</div>
            <h1 style="color: #1890ff; margin: 0; font-size: 28px;">¥{{ stats.currentFixedDeposit || 0 }}</h1>
            <div style="color: #999; font-size: 12px; margin-top: 4px;">雷打不动必存资金</div>
          </div>
        </a-col>
        <a-col :span="8">
          <div :style="{
            padding: '12px',
            background: stats.currentBalance >= 0 ? '#f6ffed' : '#fff2f0',
            border: stats.currentBalance >= 0 ? '1px solid #b7eb8f' : '1px solid #ffccc7',
            borderRadius: '8px'
          }">
            <div style="color: #666; font-size: 14px; margin-bottom: 8px;">本期结余 / 超支</div>
            <h1 :style="{ color: stats.currentBalance >= 0 ? '#52c41a' : '#ff4d4f', margin: 0, fontSize: '28px' }">
              {{ stats.currentBalance >= 0 ? '+¥' + stats.currentBalance : '-¥' + Math.abs(stats.currentBalance) }}
            </h1>
            <div :style="{ color: stats.currentBalance >= 0 ? '#52c41a' : '#ff4d4f', fontSize: '12px', marginTop: '4px' }">
              {{ stats.currentBalance >= 0 ? '日常消费有结余 (推进目标)' : '警告：日常开销超支！' }}
            </div>
          </div>
        </a-col>
        <a-col :span="8">
          <div :style="{
            padding: '12px',
            background: stats.currentFinalBalance >= 0 ? '#f6ffed' : '#fff2f0',
            border: stats.currentFinalBalance >= 0 ? '1px solid #b7eb8f' : '1px solid #ffccc7',
            borderRadius: '8px'
          }">
            <div style="color: #666; font-size: 14px; margin-bottom: 8px;">最终结余 (净沉淀)</div>
            <h1 :style="{ color: stats.currentFinalBalance >= 0 ? '#52c41a' : '#ff4d4f', margin: 0, fontSize: '28px' }">
              {{ stats.currentFinalBalance >= 0 ? '¥' + stats.currentFinalBalance : '-¥' + Math.abs(stats.currentFinalBalance) }}
            </h1>
            <div :style="{ color: stats.currentFinalBalance >= 0 ? '#52c41a' : '#ff4d4f', fontSize: '12px', marginTop: '4px' }">
              固存 + 结余/超支 (本期最终留存)
            </div>
          </div>
        </a-col>
      </a-row>
    </a-card>

    <!-- 第三行：分类支出饼图 与 历史周期透视列表 -->
    <a-row :gutter="16">
      <a-col :span="10">
        <a-card title="本周期分类支出占比">
          <v-chart class="chart" :option="pieOption" style="height: 380px" />
        </a-card>
      </a-col>
      <a-col :span="14">
        <a-card title="各周期结余/超支透视表">
          <a-table :dataSource="cycles" :columns="cycleColumns" rowKey="id" :pagination="false" size="small">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'period'">
                {{ record.cycleStartDate }} ~ {{ record.cycleEndDate }}
              </template>
              <template v-else-if="column.key === 'fixedDeposit'">
                ¥{{ getCycleDeposit(record) }}
              </template>
              <template v-else-if="column.key === 'balance'">
                <span :style="{ color: record.balance >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }">
                  {{ record.balance >= 0 ? '+¥' + record.balance : '-¥' + Math.abs(record.balance) }}
                </span>
              </template>
              <template v-else-if="column.key === 'finalBalance'">
                <span :style="{ color: (getCycleDeposit(record) + record.balance) >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }">
                  ¥{{ (getCycleDeposit(record) + record.balance).toFixed(2) }}
                </span>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>

    <!-- 第四行：长期资产目标快捷实现 与 心愿单快捷兑现 -->
    <a-row :gutter="16" style="margin-top: 24px;">
      <a-col :span="12">
        <a-card title="长期资产目标快捷实现">
          <a-table :dataSource="longTermTargets" :columns="longTermColumns" rowKey="id" :pagination="false" size="small">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'targetAmount'">
                ¥{{ record.targetAmount }}
              </template>
              <template v-else-if="column.key === 'progress'">
                <a-progress :percent="record.progress || 0"
                            :status="(record.progress || 0) >= 100 ? 'success' : 'active'" />
              </template>
              <template v-else-if="column.key === 'estimatedCompletionDate'">
                <span v-if="record.isRealized === 1">-</span>
                <a-tag v-else-if="record.estimatedCompletionDate === '当前可实现'" color="green">
                  当前可实现
                </a-tag>
                <a-tooltip v-else-if="record.estimatedCompletionDate === '无法预估'" :title="record.estimatedReason || '存钱速度无盈余，无法预估'">
                  <a-tag color="default">无法预估</a-tag>
                </a-tooltip>
                <a-tooltip v-else-if="record.isEstimatedFallback" :title="record.estimatedReason">
                  <a-tag color="orange" style="cursor: pointer;">
                    {{ record.estimatedCompletionDate }} ⚠
                  </a-tag>
                </a-tooltip>
                <a-tooltip v-else :title="record.estimatedReason">
                  <span style="color: #722ed1; font-weight: 500;">
                    {{ record.estimatedCompletionDate }}
                  </span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space v-if="record.isRealized === 1">
                  <a-tag color="green">已实现</a-tag>
                  <a-popconfirm title="确定撤销该目标的实现状态吗？扣款流水将被删除并退回账户余额" @confirm="handleUnrealize(record)">
                    <a style="color: #ff4d4f; font-size: 12px;">撤销</a>
                  </a-popconfirm>
                </a-space>
                <template v-else>
                  <a-tooltip :title="stats.totalAssets < record.targetAmount ? `当前总资产不足以实现此目标 (缺口: ¥${record.gap || 0})` : ''">
                    <a-button
                      type="primary"
                      size="small"
                      :disabled="stats.totalAssets < record.targetAmount"
                      @click="showRealizeModal(record)">
                      实现目标
                    </a-button>
                  </a-tooltip>
                </template>
              </template>
            </template>
          </a-table>
        </a-card>
      </a-col>

      <a-col :span="12">
        <a-card title="心愿单快捷兑现">
          <a-table :dataSource="wishlistTargets" :columns="wishlistColumns" rowKey="id" :pagination="false" size="small">
            <template #bodyCell="{ column, record }">
              <template v-if="column.key === 'targetAmount'">
                ¥{{ record.targetAmount }}
              </template>
              <template v-else-if="column.key === 'progress'">
                <a-progress :percent="record.progress || 0"
                            :stroke-color="record.isRealized === 1 ? '#52c41a' : '#eb2f96'"
                            :status="(record.progress || 0) >= 100 ? 'success' : 'active'" />
              </template>
              <template v-else-if="column.key === 'estimatedCompletionDate'">
                <span v-if="record.isRealized === 1">-</span>
                <a-tag v-else-if="record.estimatedCompletionDate === '当前可实现'" color="green">
                  当前可实现
                </a-tag>
                <a-tooltip v-else-if="record.estimatedCompletionDate === '无法预估'" :title="record.estimatedReason || '存钱速度无盈余，无法预估'">
                  <a-tag color="default">无法预估</a-tag>
                </a-tooltip>
                <a-tooltip v-else-if="record.isEstimatedFallback" :title="record.estimatedReason">
                  <a-tag color="orange" style="cursor: pointer;">
                    {{ record.estimatedCompletionDate }} ⚠
                  </a-tag>
                </a-tooltip>
                <a-tooltip v-else :title="record.estimatedReason">
                  <span style="color: #eb2f96; font-weight: 500;">
                    {{ record.estimatedCompletionDate }}
                  </span>
                </a-tooltip>
              </template>
              <template v-else-if="column.key === 'action'">
                <a-space v-if="record.isRealized === 1">
                  <a-tag color="green">已兑现</a-tag>
                  <a-popconfirm title="确定撤销该心愿的兑现状态吗？扣款流水将被删除并退回账户余额" @confirm="handleUnrealize(record)">
                    <a style="color: #ff4d4f; font-size: 12px;">撤销</a>
                  </a-popconfirm>
                </a-space>
                <template v-else>
                  <a-tooltip :title="stats.cumulativeBalance < record.targetAmount ? `当前累计结余不足 (¥${stats.cumulativeBalance})，点击可任性兑现` : ''">
                    <a-button
                      type="primary"
                      size="small"
                      :style="stats.cumulativeBalance < record.targetAmount ? { background: '#eb2f96', borderColor: '#eb2f96' } : {}"
                      @click="showRealizeModal(record)">
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
    <a-modal v-model:open="realizeVisible" :title="realizeTargetRecord?.type === 'LONG_TERM' ? '实现长期目标（扣款设定）' : '兑现心愿（扣款设定）'" @ok="handleRealizeOk">
      <div v-if="realizeTargetRecord?.type !== 'LONG_TERM' && stats.cumulativeBalance < (realizeTargetRecord?.targetAmount || 0)" style="margin-bottom: 16px;">
        <a-alert
          type="warning"
          show-icon
          message="结余超支软警告"
          :description="`当前全局累计结余为 ¥${stats.cumulativeBalance}，小于心愿金额 ¥${realizeTargetRecord?.targetAmount}。兑现此心愿将导致结余超支或动用老本储蓄。兑现心愿完全看心情，确定要任性实现吗？`"
        />
      </div>
      <a-form :label-col="{ span: 6 }" :wrapper-col="{ span: 16 }">
        <a-form-item label="扣款账户" required :help="realizeTargetRecord?.type === 'LONG_TERM' ? '实现目标将生成一笔真实支出记录，分类自动绑定为【目标】' : '兑现心愿将生成一笔真实支出记录，分类自动绑定为【目标】'">
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
import { message } from 'ant-design-vue';
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { PieChart } from 'echarts/charts';
import { TitleComponent, TooltipComponent, LegendComponent } from 'echarts/components';
import VChart from 'vue-echarts';
import request from '../utils/request';

use([CanvasRenderer, PieChart, TitleComponent, TooltipComponent, LegendComponent]);

const stats = ref({
  totalAssets: 0,
  totalTargets: 0,
  targetAllocated: 0,
  cumulativeBalance: 0,
  availableAssets: 0,
  isOverdraft: false,
  currentIncome: 0,
  currentExpense: 0,
  currentFixedDeposit: 0,
  currentBalance: 0,
  currentFinalBalance: 0,
  categoryExpenses: []
});

const cycles = ref<any[]>([]);
const targets = ref<any[]>([]);
const accounts = ref<any[]>([]);

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '固存', key: 'fixedDeposit' },
  { title: '本期结余/超支', key: 'balance' },
  { title: '最终结余 (固存+结余)', key: 'finalBalance' }
];

const longTermColumns = [
  { title: '目标名称', dataIndex: 'name', key: 'name' },
  { title: '目标金额', key: 'targetAmount' },
  { title: '总资产进度', key: 'progress' },
  { title: '预计实现时间', key: 'estimatedCompletionDate' },
  { title: '操作', key: 'action' }
];

const wishlistColumns = [
  { title: '心愿名称', dataIndex: 'name', key: 'name' },
  { title: '心愿金额', key: 'targetAmount' },
  { title: '结余进度', key: 'progress' },
  { title: '预计达成时间', key: 'estimatedCompletionDate' },
  { title: '操作', key: 'action' }
];

const longTermTargets = computed(() => {
  return targets.value.filter(t => t.type === 'LONG_TERM');
});

const wishlistTargets = computed(() => {
  return targets.value.filter(t => t.type !== 'LONG_TERM');
});

const getCycleDeposit = (record: any) => {
  if (!record.fixedItems) return 0;
  return record.fixedItems.reduce((acc: number, item: any) => {
    return item.type === 'DEPOSIT' ? acc + (Number(item.amount) || 0) : acc;
  }, 0);
};

// 快捷实现目标 / 心愿
const realizeVisible = ref(false);
const realizeTargetId = ref<number | null>(null);
const realizeTargetRecord = ref<any>(null);
const realizeAccountId = ref<number | null>(null);

const showRealizeModal = (record: any) => {
  realizeTargetRecord.value = record;
  realizeTargetId.value = record.id;
  realizeAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!realizeAccountId.value) {
    message.error('请选择扣款账户');
    return;
  }
  try {
    await request.post(`/targets/${realizeTargetId.value}/realize`, { accountId: realizeAccountId.value });
    const isLongTerm = realizeTargetRecord.value?.type === 'LONG_TERM';
    message.success(isLongTerm ? '目标实现成功！账户已扣款' : '心愿兑现成功！账户已扣款');
    realizeVisible.value = false;
    refreshData();
  } catch (e) {}
};

const handleUnrealize = async (record: any) => {
  try {
    await request.post(`/targets/${record.id}/unrealize`);
    const isLongTerm = record.type === 'LONG_TERM';
    message.success(isLongTerm ? '已成功撤销目标实现状态，资金已退回账户！' : '已成功撤销心愿兑现状态，资金已退回账户！');
    refreshData();
  } catch (e) {}
};

const pieOption = computed(() => {
  return {
    tooltip: { trigger: 'item' },
    legend: { orient: 'vertical', left: 'left' },
    series: [
      {
        name: '分类支出',
        type: 'pie',
        radius: '50%',
        data: stats.value.categoryExpenses,
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  };
});

const refreshData = async () => {
  stats.value = await request.get('/stats');
  cycles.value = await request.get('/cycles');
  targets.value = await request.get('/targets');
  accounts.value = await request.get('/accounts');
};

onMounted(() => {
  refreshData();
});
</script>
