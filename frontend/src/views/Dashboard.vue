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

    <a-row :gutter="16" style="margin-bottom: 24px;">
      <a-col :span="6">
        <a-card title="总资产">
          <h2 :style="{ color: stats.totalAssets < 0 ? 'red' : 'inherit' }">¥{{ stats.totalAssets }}</h2>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="目标预留">
          <h2>¥{{ stats.totalTargets }} (已分配: ¥{{ stats.targetAllocated }})</h2>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="本周期收入">
          <h2 style="color: green">¥{{ stats.currentIncome }}</h2>
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card title="本周期支出">
          <h2 style="color: red">¥{{ stats.currentExpense }}</h2>
        </a-card>
      </a-col>
    </a-row>

    <a-row :gutter="16">
      <a-col :span="12">
        <a-card title="本周期分类支出占比">
          <v-chart class="chart" :option="pieOption" style="height: 400px" />
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
  isOverdraft: false,
  currentIncome: 0,
  currentExpense: 0,
  currentBalance: 0,
  categoryExpenses: []
});

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
});
</script>
