<template>
  <main>
    <van-nav-bar title="用户管理" left-arrow right-text="创建用户" @click-left="router.push('/mine')" @click-right="openCreate" />
    <van-search v-model="keyword" placeholder="搜索用户名" @search="search" @clear="search" />
    <van-dropdown-menu><van-dropdown-item v-model="statusFilter" :options="statusOptions" @change="search" /></van-dropdown-menu>
    <van-pull-refresh v-model="refreshing" @refresh="search">
      <van-empty v-if="!users.length && !loading" description="暂无普通用户" />
      <van-cell-group inset v-for="user in users" :key="user.id" style="margin-top: 12px">
        <van-cell :title="user.username" :value="user.status === 'ACTIVE' ? '启用' : '停用'" :label="`创建于 ${user.createdAt || '-'}${user.mustChangePassword ? ' · 待改密' : ''}`" />
        <div class="user-actions">
          <van-button size="small" :disabled="busy" @click="toggle(user)">{{ user.status === 'ACTIVE' ? '停用' : '启用' }}</van-button>
          <van-button size="small" :disabled="busy" @click="openReset(user)">重置密码</van-button>
          <van-button size="small" type="danger" plain :disabled="busy" @click="remove(user)">删除</van-button>
        </div>
      </van-cell-group>
      <van-pagination v-if="total > 20" v-model="page" :total-items="total" :items-per-page="20" mode="simple" style="padding: 20px" @change="load" />
    </van-pull-refresh>
    <van-popup v-model:show="showEditor" position="bottom" round safe-area-inset-bottom @closed="password = ''">
      <h3 style="text-align: center">{{ editing ? `重置 ${editing.username} 的密码` : '创建普通用户' }}</h3>
      <van-form @submit="save">
        <van-cell-group inset>
          <van-field v-if="!editing" v-model="username" label="用户名" :rules="[{ required: true, message: '请输入用户名' }]" autocomplete="off" />
          <van-field v-model="password" type="password" label="临时密码" autocomplete="new-password" :rules="[{ validator: validPassword, message: '至少8位，UTF-8长度不超过72字节' }]" />
        </van-cell-group>
        <p class="help">用户下次登录必须修改密码，重置会撤销全部会话。</p>
        <div class="editor-actions"><van-button block round type="primary" native-type="submit" :loading="busy">保存</van-button><van-button block round style="margin-top: 12px" @click="showEditor = false">取消</van-button></div>
      </van-form>
    </van-popup>
  </main>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { showConfirmDialog, showToast } from 'vant';
import { adminService } from '../services/adminService';
import { validPassword, type UserProfile } from '../state/session';
const router = useRouter();
const users = ref<UserProfile[]>([]);
const keyword = ref(''); const statusFilter = ref(''); const page = ref(1); const total = ref(0);
const refreshing = ref(false); const loading = ref(false); const busy = ref(false); const showEditor = ref(false);
const editing = ref<UserProfile | null>(null); const username = ref(''); const password = ref('');
const statusOptions = [{ text: '全部状态', value: '' }, { text: '启用', value: 'ACTIVE' }, { text: '停用', value: 'DISABLED' }];
let loadId = 0;
async function load() {
  const id = ++loadId; loading.value = true;
  try { const data = await adminService.list(page.value, keyword.value.trim(), statusFilter.value); if (id === loadId) { users.value = data.records; total.value = data.total; } }
  catch { /* Shared request displays the error. */ }
  finally { if (id === loadId) loading.value = false; refreshing.value = false; }
}
function search() { page.value = 1; void load(); }
function openCreate() { editing.value = null; username.value = ''; password.value = ''; showEditor.value = true; }
function openReset(user: UserProfile) { editing.value = user; password.value = ''; showEditor.value = true; }
async function save() {
  if (busy.value) return; busy.value = true;
  try { if (editing.value) await adminService.reset(editing.value.id, password.value); else await adminService.create(username.value.trim(), password.value); showEditor.value = false; password.value = ''; showToast('保存成功'); await load(); }
  catch { /* Shared request displays the error. */ } finally { busy.value = false; }
}
async function toggle(user: UserProfile) {
  try {
    const status = user.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE';
    await showConfirmDialog({ title: status === 'DISABLED' ? '停用用户' : '启用用户', message: status === 'DISABLED' ? `停用 ${user.username} 后，其全部会话将失效，自动任务暂停。` : `确认重新启用 ${user.username}？` });
    busy.value = true; await adminService.status(user.id, status); await load();
  } catch { /* Cancellation or shared request error. */ } finally { busy.value = false; }
}
async function remove(user: UserProfile) {
  try { await showConfirmDialog({ title: '删除用户', message: `删除 ${user.username} 后禁止登录且无法恢复；财务数据保留，用户名继续占用。确认删除？`, confirmButtonColor: '#ee0a24' }); busy.value = true; await adminService.delete(user.id); search(); }
  catch { /* Cancellation or shared request error. */ } finally { busy.value = false; }
}
onMounted(load);
</script>
<style scoped>
.user-actions { display: flex; gap: 8px; padding: 8px 16px 16px; justify-content: flex-end; }
.editor-actions { padding: 12px 16px 24px; }
.help { color: #646566; padding: 0 16px; font-size: 12px; }
</style>
