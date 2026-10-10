<template>
  <div style="padding: 24px;">
    <a-alert
      v-if="stats.isOverdraft"
      message="警告：全局目标透支！"
      description="您的总目标预留资金已超过当前总资产！"
      type="error"
      show-icon
      style="margin-bottom: 24px;"
    />

    <!-- 第一行：全局资产与收支概览 -->
    <a-row :gutter="16" style="margin-bottom: 24px;">
      <a-col :span="6">
        <a-card title="总资产 (账户资金和)">
          <h2 style="margin-bottom: 4px;">¥{{ stats.totalAssets }}</h2>
          <div style="font-size: 13px; color: #666;">
            扣除目标后可用:
            <span :style="{ color: stats.availableAssets >= 0 ? '#52c41a' : '#ff4d4f', fontWeight: 'bold' }">
              ¥{{ stats.availableAssets }}
            </span>
          </div>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="目标资金预留">
          <h2 style="margin-bottom: 4px;">¥{{ stats.totalTargets }}</h2>
          <div style="font-size: 13px; color: #666;">
            累计可用结余:
            <span :style="{ fontWeight: 'bold', color: stats.cumulativeBalance >= 0 ? '#52c41a' : '#ff4d4f' }">
              ¥{{ stats.cumulativeBalance }}
            </span>
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
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
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

const cycleColumns = [
  { title: '周期区间', key: 'period' },
  { title: '固存', key: 'fixedDeposit' },
  { title: '本期结余/超支', key: 'balance' },
  { title: '最终结余 (固存+结余)', key: 'finalBalance' }
];

const getCycleDeposit = (record: any) => {
  if (!record.fixedItems) return 0;
  return record.fixedItems.reduce((acc: number, item: any) => {
    return item.type === 'DEPOSIT' ? acc + (Number(item.amount) || 0) : acc;
  }, 0);
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

onMounted(async () => {
  stats.value = await request.get('/stats');
  cycles.value = await request.get('/cycles');
});
</script>
