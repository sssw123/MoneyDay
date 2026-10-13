<template>
  <div class="plan-page">
    <van-nav-bar title="未来计划" fixed placeholder>
      <template #right>
        <van-icon name="plus" size="18" @click="openAddModal" />
      </template>
    </van-nav-bar>

    <van-tabs v-model:active="activeTab" sticky color="#1989fa">
      <!-- 1. 心愿单 -->
      <van-tab title="心愿单" name="wishlist">
        <div class="tab-content">
          <div v-if="wishlists.length === 0" style="padding: 40px 0; text-align: center;">
            <van-empty description="暂无心愿清单，快许个愿吧！" />
          </div>
          <div v-else class="card-list">
            <div class="item-card" v-for="item in wishlists" :key="item.id">
              <div class="card-header">
                <span class="card-title">{{ item.name }}</span>
                <van-tag :type="item.isRealized ? 'success' : 'primary'" size="medium">
                  {{ item.isRealized ? '已兑现' : `进度 ${item.progress || 0}%` }}
                </van-tag>
              </div>
              <div class="card-body">
                <div class="info-row">
                  <span class="info-label">心愿目标</span>
                  <span class="info-val">¥{{ formatNum(item.targetAmount) }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">预计实现</span>
                  <span class="info-val info-purple">{{ item.estimatedCompletionDate || '无法预估' }}</span>
                </div>
                <div class="progress-wrap" v-if="!item.isRealized">
                  <van-progress :percentage="item.progress || 0" stroke-width="4" color="#07c160" :show-pivot="false" />
                </div>
              </div>
              <div class="card-footer">
                <template v-if="item.isRealized">
                  <span style="font-size: 12px; color: #07c160;">🎉 心愿已达成</span>
                  <van-button size="mini" type="danger" plain @click="unrealizeWishlist(item.id)">撤销</van-button>
                </template>
                <template v-else>
                  <van-button size="small" type="primary" color="#07c160" @click="openRealizeModal(item, 'WISHLIST')">
                    兑现心愿
                  </van-button>
                  <van-button size="small" plain type="danger" @click="deleteWishlist(item.id)">删除</van-button>
                </template>
              </div>
            </div>
          </div>
        </div>
      </van-tab>

      <!-- 2. 长期目标 -->
      <van-tab title="资产目标" name="target">
        <div class="tab-content">
          <div v-if="targets.length === 0" style="padding: 40px 0; text-align: center;">
            <van-empty description="暂无长期资产目标" />
          </div>
          <div v-else class="card-list">
            <div class="item-card" v-for="item in targets" :key="item.id">
              <div class="card-header">
                <span class="card-title">{{ item.name }}</span>
                <van-tag :type="item.isRealized ? 'success' : 'primary'" size="medium">
                  {{ item.isRealized ? '已达成' : `进度 ${item.progress || 0}%` }}
                </van-tag>
              </div>
              <div class="card-body">
                <div class="info-row">
                  <span class="info-label">目标金额</span>
                  <span class="info-val">¥{{ formatNum(item.targetAmount) }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">预计达成</span>
                  <span class="info-val info-purple">{{ item.estimatedCompletionDate || '无法预估' }}</span>
                </div>
                <div class="progress-wrap" v-if="!item.isRealized">
                  <van-progress :percentage="item.progress || 0" stroke-width="4" color="#7232dd" :show-pivot="false" />
                </div>
              </div>
              <div class="card-footer">
                <template v-if="item.isRealized">
                  <span style="font-size: 12px; color: #07c160;">🏆 目标已实现</span>
                  <van-button size="mini" type="danger" plain @click="unrealizeTarget(item.id)">撤销</van-button>
                </template>
                <template v-else>
                  <van-button size="small" type="primary" color="#7232dd" @click="openRealizeModal(item, 'TARGET')">
                    达成实现
                  </van-button>
                  <van-button size="small" plain type="danger" @click="deleteTarget(item.id)">删除</van-button>
                </template>
              </div>
            </div>
          </div>
        </div>
      </van-tab>

      <!-- 3. 透支分期 -->
      <van-tab title="透支分期" name="liability">
        <div class="tab-content">
          <div v-if="liabilities.length === 0" style="padding: 40px 0; text-align: center;">
            <van-empty description="暂无透支分期负债，无债一身轻！" />
          </div>
          <div v-else class="card-list">
            <div class="item-card" v-for="item in liabilities" :key="item.id">
              <div class="card-header">
                <span class="card-title">{{ item.name }}</span>
                <van-tag :type="item.status === 'SETTLED' ? 'success' : 'danger'" size="medium">
                  {{ item.status === 'SETTLED' ? '已结清' : `还款中 (${item.currentPeriod}/${item.totalPeriods}期)` }}
                </van-tag>
              </div>
              <div class="card-body">
                <div class="info-row">
                  <span class="info-label">每期应还</span>
                  <span class="info-val text-danger">¥{{ formatNum(item.periodAmount) }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">下期还款日</span>
                  <span class="info-val info-purple">{{ item.nextRepaymentDate || '已结清' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">总待还额</span>
                  <span class="info-val">¥{{ formatNum(item.totalAmount) }}</span>
                </div>
                <div class="progress-wrap" v-if="item.status !== 'SETTLED'">
                  <van-progress :percentage="calcProgress(item.currentPeriod, item.totalPeriods)" stroke-width="4" color="#ee0a24" :show-pivot="false" />
                </div>
              </div>
              <div class="card-footer" v-if="item.status !== 'SETTLED'">
                <van-button size="small" type="danger" @click="openRepayModal(item)">还款</van-button>
                <van-button size="small" plain type="primary" @click="openSettleModal(item)">提前结清</van-button>
                <van-button size="small" plain type="danger" @click="deleteLiability(item.id)">删除</van-button>
              </div>
            </div>
          </div>
        </div>
      </van-tab>
    </van-tabs>

    <!-- 实现/兑现弹窗 -->
    <van-popup v-model:show="realizeVisible" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="realizeVisible = false">取消</span>
          <span class="title">{{ realizeType === 'WISHLIST' ? '兑现心愿' : '实现目标' }}</span>
          <span class="confirm" @click="handleRealizeOk">确认</span>
        </div>
        <div style="padding: 12px 16px;">
          <p><b>项目：</b>{{ currentRealizeItem?.name }}</p>
          <p><b>金额：</b>¥{{ currentRealizeItem?.targetAmount }}</p>
        </div>
        <van-cell-group inset>
          <van-cell title="扣款账户" is-link :value="selectedAccountName || '请选择账户'" @click="showAccountPicker = true" required />
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 还款弹窗 -->
    <van-popup v-model:show="repayVisible" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="repayVisible = false">取消</span>
          <span class="title">分期还款</span>
          <span class="confirm" @click="handleRepayOk">确认</span>
        </div>
        <div style="padding: 12px 16px;">
          <p><b>分期项目：</b>{{ currentLiability?.name }}</p>
          <p><b>每期金额：</b>¥{{ currentLiability?.periodAmount }}</p>
        </div>
        <van-cell-group inset>
          <van-field v-model="repayPeriodsNum" type="digit" label="还款期数" placeholder="1" input-align="right" required />
          <van-field v-model="repayAmount" type="number" label="还款金额" placeholder="0.00" input-align="right" required />
          <van-cell title="扣款账户" is-link :value="selectedAccountName || '请选择账户'" @click="showAccountPicker = true" required />
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 提前结清弹窗 -->
    <van-popup v-model:show="settleVisible" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="settleVisible = false">取消</span>
          <span class="title">提前结清</span>
          <span class="confirm" @click="handleSettleOk">确认结清</span>
        </div>
        <div style="padding: 12px 16px;">
          <p><b>结清项目：</b>{{ currentLiability?.name }}</p>
        </div>
        <van-cell-group inset>
          <van-field v-model="settleAmount" type="number" label="结清总额" placeholder="0.00" input-align="right" required />
          <van-cell title="扣款账户" is-link :value="selectedAccountName || '请选择账户'" @click="showAccountPicker = true" required />
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 新建弹窗 -->
    <van-popup v-model:show="showAddPopup" position="bottom" round safe-area-inset-bottom :style="{ height: '65%' }">
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="showAddPopup = false">取消</span>
          <span class="title">{{ getAddTitle() }}</span>
          <span class="confirm" @click="handleAddSubmit">保存</span>
        </div>

        <van-cell-group inset style="margin-top: 12px;">
          <van-field v-model="addForm.name" label="名称" placeholder="输入名称" input-align="right" required />
          <template v-if="activeTab === 'wishlist' || activeTab === 'target'">
            <van-field v-model="addForm.targetAmount" type="number" label="目标金额" placeholder="0.00" input-align="right" required />
          </template>
          <template v-else>
            <van-field v-model="addForm.principal" type="number" label="分期本金" placeholder="0.00" input-align="right" required />
            <van-field v-model="addForm.totalPeriods" type="digit" label="分期期数" placeholder="如 12" input-align="right" required />
            <van-field v-model="addForm.periodAmount" type="number" label="每期金额" placeholder="0.00" input-align="right" required />
            <van-field v-model="addForm.repaymentDay" type="digit" label="每月还款日" placeholder="1-31" input-align="right" required />
            <van-cell title="扣款账户" is-link :value="selectedAccountName || '请选择账户'" @click="showAccountPicker = true" required />
          </template>
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 账户选择器 -->
    <van-popup v-model:show="showAccountPicker" position="bottom" round>
      <van-picker title="选择账户" :columns="accountColumns" @confirm="onAccountConfirm" @cancel="showAccountPicker = false" />
    </van-popup>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, computed } from 'vue';
import { showToast, showConfirmDialog } from 'vant';
import request from '../utils/request';

const activeTab = ref('wishlist');
const wishlists = ref<any[]>([]);
const targets = ref<any[]>([]);
const liabilities = ref<any[]>([]);
const accounts = ref<any[]>([]);

// 弹窗状态
const realizeVisible = ref(false);
const realizeType = ref('WISHLIST');
const currentRealizeItem = ref<any>(null);

const repayVisible = ref(false);
const settleVisible = ref(false);
const currentLiability = ref<any>(null);
const repayPeriodsNum = ref('1');
const repayAmount = ref('');
const settleAmount = ref('');

const selectedAccountId = ref<number | null>(null);
const showAccountPicker = ref(false);

const showAddPopup = ref(false);
const addForm = ref<any>({});

const formatNum = (val: any) => Number(val || 0).toFixed(2);
const calcProgress = (cur: number, total: number) => !total ? 0 : Math.min(100, Math.round((cur / total) * 100));

const getAccountName = (id: number) => {
  const a = accounts.value.find((acc: any) => acc.id === id);
  return a ? a.name : '';
};
const selectedAccountName = computed(() => selectedAccountId.value ? getAccountName(selectedAccountId.value) : '');

const accountColumns = computed(() => {
  return accounts.value.map((a: any) => ({
    text: `${a.name} (¥${a.currentBalance})`,
    value: a.id
  }));
});

const fetchData = async () => {
  try {
    const [w, t, l, a] = await Promise.all([
      request.get('/wishlists'),
      request.get('/targets'),
      request.get('/liabilities'),
      request.get('/accounts')
    ]);
    wishlists.value = w || [];
    targets.value = t || [];
    liabilities.value = l || [];
    accounts.value = a || [];
  } catch (e) {}
};

const onAccountConfirm = ({ selectedOptions }: any) => {
  if (selectedOptions[0]) {
    selectedAccountId.value = selectedOptions[0].value;
  }
  showAccountPicker.value = false;
};

// 兑现心愿 / 目标
const openRealizeModal = (item: any, type: string) => {
  currentRealizeItem.value = item;
  realizeType.value = type;
  selectedAccountId.value = accounts.value.length > 0 ? accounts.value[0].id : null;
  realizeVisible.value = true;
};

const handleRealizeOk = async () => {
  if (!selectedAccountId.value) {
    showToast('请选择扣款账户');
    return;
  }
  try {
    if (realizeType.value === 'WISHLIST') {
      await request.post(`/wishlists/${currentRealizeItem.value.id}/realize`, {
        accountId: selectedAccountId.value
      });
    } else {
      await request.post(`/targets/${currentRealizeItem.value.id}/realize`, {
        accountId: selectedAccountId.value
      });
    }
    showToast({ type: 'success', message: '操作成功' });
    realizeVisible.value = false;
    fetchData();
  } catch (e) {}
};

// 撤销兑现
const unrealizeWishlist = (id: number) => {
  showConfirmDialog({ title: '确认撤销', message: '确定撤销该心愿的实现状态吗？扣款流水将被删除并退回余额' }).then(async () => {
    try {
      await request.post(`/wishlists/${id}/unrealize`);
      showToast({ type: 'success', message: '已撤销' });
      fetchData();
    } catch (e) {}
  });
};

const unrealizeTarget = (id: number) => {
  showConfirmDialog({ title: '确认撤销', message: '确定撤销该目标的实现状态吗？扣款流水将被删除并退回余额' }).then(async () => {
    try {
      await request.post(`/targets/${id}/unrealize`);
      showToast({ type: 'success', message: '已撤销' });
      fetchData();
    } catch (e) {}
  });
};

// 还款
const openRepayModal = (item: any) => {
  currentLiability.value = item;
  repayPeriodsNum.value = '1';
  repayAmount.value = String(item.periodAmount || '');
  selectedAccountId.value = item.defaultAccountId || (accounts.value[0]?.id || null);
  repayVisible.value = true;
};

const handleRepayOk = async () => {
  if (!selectedAccountId.value || !repayAmount.value) {
    showToast('请填写完整还款信息');
    return;
  }
  try {
    await request.post(`/liabilities/${currentLiability.value.id}/repay`, {
      periods: Number(repayPeriodsNum.value),
      amount: Number(repayAmount.value),
      accountId: selectedAccountId.value
    });
    showToast({ type: 'success', message: '还款成功' });
    repayVisible.value = false;
    fetchData();
  } catch (e) {}
};

// 结清
const openSettleModal = (item: any) => {
  currentLiability.value = item;
  const rem = (item.totalPeriods - item.currentPeriod) * item.periodAmount;
  settleAmount.value = String(rem > 0 ? rem : item.periodAmount);
  selectedAccountId.value = item.defaultAccountId || (accounts.value[0]?.id || null);
  settleVisible.value = true;
};

const handleSettleOk = async () => {
  if (!selectedAccountId.value || !settleAmount.value) {
    showToast('请填写完整结清信息');
    return;
  }
  try {
    await request.post(`/liabilities/${currentLiability.value.id}/settle`, {
      settleAmount: Number(settleAmount.value),
      accountId: selectedAccountId.value
    });
    showToast({ type: 'success', message: '已提前结清！' });
    settleVisible.value = false;
    fetchData();
  } catch (e) {}
};

// 删除
const deleteWishlist = (id: number) => {
  showConfirmDialog({ title: '确认删除', message: '确定删除该心愿吗？' }).then(async () => {
    await request.delete(`/wishlists/${id}`);
    showToast({ type: 'success', message: '已删除' });
    fetchData();
  });
};

const deleteTarget = (id: number) => {
  showConfirmDialog({ title: '确认删除', message: '确定删除该目标吗？' }).then(async () => {
    await request.delete(`/targets/${id}`);
    showToast({ type: 'success', message: '已删除' });
    fetchData();
  });
};

const deleteLiability = (id: number) => {
  showConfirmDialog({ title: '确认删除', message: '确定删除该分期吗？历史扣款流水将保留' }).then(async () => {
    await request.delete(`/liabilities/${id}`);
    showToast({ type: 'success', message: '已删除' });
    fetchData();
  });
};

// 新增
const openAddModal = () => {
  addForm.value = {
    name: '',
    targetAmount: '',
    principal: '',
    totalPeriods: '',
    periodAmount: '',
    repaymentDay: '10'
  };
  selectedAccountId.value = accounts.value[0]?.id || null;
  showAddPopup.value = true;
};

const getAddTitle = () => {
  if (activeTab.value === 'wishlist') return '新建心愿';
  if (activeTab.value === 'target') return '新建目标';
  return '录入分期';
};

const handleAddSubmit = async () => {
  if (!addForm.value.name) {
    showToast('请输入名称');
    return;
  }
  try {
    if (activeTab.value === 'wishlist') {
      await request.post('/wishlists', {
        name: addForm.value.name,
        targetAmount: Number(addForm.value.targetAmount)
      });
    } else if (activeTab.value === 'target') {
      await request.post('/targets', {
        name: addForm.value.name,
        targetAmount: Number(addForm.value.targetAmount)
      });
    } else {
      await request.post('/liabilities', {
        name: addForm.value.name,
        principal: Number(addForm.value.principal),
        totalPeriods: Number(addForm.value.totalPeriods),
        periodAmount: Number(addForm.value.periodAmount),
        repaymentDay: Number(addForm.value.repaymentDay),
        defaultAccountId: selectedAccountId.value,
        rateType: 'NONE'
      });
    }
    showToast({ type: 'success', message: '创建成功' });
    showAddPopup.value = false;
    fetchData();
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.plan-page {
  padding-bottom: 20px;
}

.tab-content {
  padding: 12px 16px;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.item-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.04);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-bottom: 1px solid #f2f3f5;
  padding-bottom: 8px;
  margin-bottom: 10px;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  color: #323233;
}

.info-row {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
  margin-bottom: 6px;
}

.info-label {
  color: #969799;
}

.info-val {
  font-weight: 500;
  color: #323233;
}

.info-purple {
  color: #7232dd;
}

.text-danger {
  color: #ee0a24;
}

.progress-wrap {
  margin: 10px 0 6px 0;
}

.card-footer {
  display: flex;
  justify-content: flex-end;
  gap: 8px;
  border-top: 1px dashed #ebedf0;
  padding-top: 10px;
  margin-top: 10px;
  align-items: center;
}

.popup-box {
  padding-bottom: 20px;
}

.popup-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  border-bottom: 1px solid #f2f3f5;
}

.popup-header .title {
  font-weight: 600;
  font-size: 16px;
}

.popup-header .cancel {
  color: #969799;
  font-size: 14px;
}

.popup-header .confirm {
  color: #1989fa;
  font-weight: 500;
  font-size: 14px;
}
</style>
