<template>
  <div class="mine-page">
    <van-nav-bar title="系统设置" fixed placeholder />

    <div class="content-box">
      <!-- 个人信息概览 -->
      <div class="user-card">
        <div class="user-avatar">
          <van-icon name="user-o" size="28" color="#1989fa" />
        </div>
        <div class="user-info">
          <div class="username">MoneyDay 本地账本</div>
          <div class="sub-text">单机私有部署 · 数据安全可靠</div>
        </div>
      </div>

      <!-- 账户管理折叠面板 -->
      <div class="setting-group">
        <div class="group-header">
          <span>账户管理 ({{ accounts.length }})</span>
          <van-button size="mini" type="primary" plain @click="openAddAccount">添加账户</van-button>
        </div>
        <van-cell-group inset>
          <van-cell v-for="acc in accounts" :key="acc.id" :title="acc.name" :label="`类型: ${acc.type}`">
            <template #value>
              <span class="acc-balance">¥{{ formatNum(acc.currentBalance) }}</span>
            </template>
          </van-cell>
        </van-cell-group>
      </div>

      <!-- 分类管理 -->
      <div class="setting-group">
        <div class="group-header">
          <span>分类管理 ({{ categories.length }})</span>
          <van-button size="mini" type="primary" plain @click="openAddCategory">添加分类</van-button>
        </div>
        <van-cell-group inset>
          <van-cell
            v-for="cat in categories.slice(0, 8)"
            :key="cat.id"
            :title="cat.name"
            :label="cat.type === 1 ? '收入分类' : '支出分类'"
          >
            <template #right-icon>
              <van-switch :model-value="cat.isActive === 1" size="20" @change="(val: boolean) => toggleCategory(cat, val)" />
            </template>
          </van-cell>
        </van-cell-group>
      </div>

      <!-- 周期模板设置 -->
      <div class="setting-group" v-if="template">
        <div class="group-header">
          <span>账单周期模板</span>
          <van-button size="mini" type="primary" plain @click="saveTemplate">保存设置</van-button>
        </div>
        <van-cell-group inset>
          <van-field v-model="template.name" label="周期名称" input-align="right" />
          <van-field v-model="template.startDay" type="digit" label="起算日 (1-31)" input-align="right" />
        </van-cell-group>
      </div>
    </div>

    <!-- 添加账户弹窗 -->
    <van-popup v-model:show="showAccModal" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="showAccModal = false">取消</span>
          <span class="title">添加账户</span>
          <span class="confirm" @click="submitAddAccount">保存</span>
        </div>
        <van-cell-group inset style="margin-top: 12px;">
          <van-field v-model="accForm.name" label="账户名称" placeholder="如 招商银行/微信钱包" input-align="right" required />
          <van-field v-model="accForm.initialBalance" type="number" label="期初余额" placeholder="0.00" input-align="right" required />
        </van-cell-group>
      </div>
    </van-popup>

    <!-- 添加分类弹窗 -->
    <van-popup v-model:show="showCatModal" position="bottom" round safe-area-inset-bottom>
      <div class="popup-box">
        <div class="popup-header">
          <span class="cancel" @click="showCatModal = false">取消</span>
          <span class="title">添加分类</span>
          <span class="confirm" @click="submitAddCategory">保存</span>
        </div>
        <van-tabs v-model:active="catForm.type" type="card" color="#1989fa" style="margin: 12px 16px;">
          <van-tab title="支出" :name="2" />
          <van-tab title="收入" :name="1" />
        </van-tabs>
        <van-cell-group inset>
          <van-field v-model="catForm.name" label="分类名称" placeholder="如 餐饮/数码" input-align="right" required />
        </van-cell-group>
      </div>
    </van-popup>
  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted } from 'vue';
import { showToast } from 'vant';
import request from '../utils/request';

const accounts = ref<any[]>([]);
const categories = ref<any[]>([]);
const template = ref<any>(null);

const showAccModal = ref(false);
const accForm = ref<any>({ name: '', initialBalance: '', type: 'BANK' });

const showCatModal = ref(false);
const catForm = ref<any>({ name: '', type: 2, isActive: 1 });

const formatNum = (val: any) => Number(val || 0).toFixed(2);

const fetchData = async () => {
  try {
    const [accs, cats, tpls]: any = await Promise.all([
      request.get('/accounts'),
      request.get('/categories'),
      request.get('/cycles/templates')
    ]);
    accounts.value = accs || [];
    categories.value = cats || [];
    if (tpls && tpls.length > 0) {
      template.value = tpls[0];
    }
  } catch (e) {}
};

const openAddAccount = () => {
  accForm.value = { name: '', initialBalance: '0', type: 'BANK' };
  showAccModal.value = true;
};

const submitAddAccount = async () => {
  if (!accForm.value.name) {
    showToast('请输入账户名称');
    return;
  }
  try {
    await request.post('/accounts', {
      name: accForm.value.name,
      type: accForm.value.type,
      initialBalance: Number(accForm.value.initialBalance || 0),
      currentBalance: Number(accForm.value.initialBalance || 0)
    });
    showToast({ type: 'success', message: '添加成功' });
    showAccModal.value = false;
    fetchData();
  } catch (e) {}
};

const openAddCategory = () => {
  catForm.value = { name: '', type: 2, isActive: 1 };
  showCatModal.value = true;
};

const submitAddCategory = async () => {
  if (!catForm.value.name) {
    showToast('请输入分类名称');
    return;
  }
  try {
    await request.post('/categories', {
      name: catForm.value.name,
      type: catForm.value.type,
      isActive: 1
    });
    showToast({ type: 'success', message: '添加成功' });
    showCatModal.value = false;
    fetchData();
  } catch (e) {}
};

const toggleCategory = async (cat: any, val: boolean) => {
  try {
    await request.put(`/categories/${cat.id}`, {
      ...cat,
      isActive: val ? 1 : 0
    });
    cat.isActive = val ? 1 : 0;
    showToast('更新成功');
  } catch (e) {}
};

const saveTemplate = async () => {
  if (!template.value) return;
  try {
    await request.put(`/cycles/templates/${template.value.id}`, template.value);
    showToast({ type: 'success', message: '模板保存成功' });
  } catch (e) {}
};

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
.mine-page {
  padding-bottom: 30px;
}

.content-box {
  padding: 12px 16px;
}

.user-card {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.03);
}

.user-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: #e8f4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 14px;
}

.username {
  font-size: 16px;
  font-weight: 600;
  color: #323233;
  margin-bottom: 2px;
}

.sub-text {
  font-size: 12px;
  color: #969799;
}

.setting-group {
  margin-bottom: 18px;
}

.group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 4px 8px 4px;
  font-size: 14px;
  font-weight: 600;
  color: #323233;
}

.acc-balance {
  font-size: 14px;
  font-weight: 600;
  color: #1989fa;
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
