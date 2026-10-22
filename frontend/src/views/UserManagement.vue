<template>
  <div class="business-page">
    <div class="page-toolbar">
      <div class="toolbar-filters">
        <a-input-search v-model:value="keyword" placeholder="搜索用户名" allow-clear @search="search" />
        <a-select v-model:value="status" placeholder="全部状态" allow-clear :options="statusOptions" @change="search" />
      </div>
      <a-button type="primary" @click="openCreate">创建普通用户</a-button>
    </div>
    <a-card :bordered="false">
      <a-alert type="info" show-icon message="管理员仅管理用户，无法查看其他用户的账本。删除后数据保留，但账户无法恢复。" class="auth-notice" />
      <a-table :columns="columns" :data-source="users" :loading="loading" row-key="id" :scroll="{ x: 'max-content' }" :pagination="{ current: page, pageSize, total, showSizeChanger: true, showTotal: (n: number) => `共 ${n} 位用户` }" @change="changePage">
        <template #bodyCell="{ column, record }">
          <template v-if="column.key === 'status'"><a-tag :color="record.status === 'ACTIVE' ? 'green' : 'default'">{{ record.status === 'ACTIVE' ? '已启用' : '已停用' }}</a-tag></template>
          <template v-else-if="column.key === 'mustChangePassword'">{{ record.mustChangePassword ? '待修改密码' : '已设置' }}</template>
          <template v-else-if="column.key === 'createdAt'">{{ formatDate(record.createdAt) }}</template>
          <template v-else-if="column.key === 'actions'">
            <a-space :size="0">
              <a-popconfirm :title="record.status === 'ACTIVE' ? '停用后该用户将立即退出所有设备，确认停用？' : '确认重新启用该用户？'" @confirm="toggleStatus(record)">
                <a-button type="link" size="small" :loading="busyId === record.id">{{ record.status === 'ACTIVE' ? '停用' : '启用' }}</a-button>
              </a-popconfirm>
              <a-button type="link" size="small" :disabled="busyId === record.id" @click="openReset(record)">重置密码</a-button>
              <a-popconfirm title="删除后无法恢复，用户名继续占用，财务数据保留。确认删除？" ok-text="确认删除" :ok-button-props="{ danger: true }" @confirm="remove(record)">
                <a-button type="link" size="small" danger :disabled="busyId === record.id">删除</a-button>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </a-card>
    <a-modal v-model:open="createOpen" title="创建普通用户" :footer="null" destroy-on-close @cancel="resetForms">
      <a-form v-if="createOpen" layout="vertical" :model="createForm" @finish="create">
        <a-form-item label="用户名" name="username" :rules="[{ required: true, whitespace: true, message: '请输入用户名' }]" help="用户名不区分大小写，创建后不可修改。">
          <a-input v-model:value="createForm.username" autocomplete="off" :maxlength="64" />
        </a-form-item>
        <a-form-item label="初始密码" name="password" :rules="[passwordRule]" help="至少 8 位，首次登录必须修改。">
          <a-input-password v-model:value="createForm.password" autocomplete="new-password" />
        </a-form-item>
        <div class="modal-actions"><a-button @click="createOpen = false; resetForms()">取消</a-button><a-button type="primary" html-type="submit" :loading="saving">创建用户</a-button></div>
      </a-form>
    </a-modal>
    <a-modal v-model:open="resetOpen" :title="`重置密码 · ${selected?.username ?? ''}`" :footer="null" destroy-on-close @cancel="resetForms">
      <a-form v-if="resetOpen" layout="vertical" :model="resetForm" @finish="resetPassword">
        <a-alert type="warning" show-icon message="重置后该用户将退出所有设备，下次登录必须修改密码。" class="auth-notice" />
        <a-form-item label="临时密码" name="password" :rules="[passwordRule]"><a-input-password v-model:value="resetForm.password" autocomplete="new-password" /></a-form-item>
        <div class="modal-actions"><a-button @click="resetOpen = false; resetForms()">取消</a-button><a-button type="primary" html-type="submit" :loading="saving">确认重置</a-button></div>
      </a-form>
    </a-modal>
  </div>
</template>
<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import request from '../utils/request'
import { passwordRule } from '../auth/session'
import type { UserProfile } from '../auth/session'
const users = ref<UserProfile[]>([])
const keyword = ref('')
const status = ref<string>()
const page = ref(1)
const pageSize = ref(20)
const total = ref(0)
const loading = ref(false)
const saving = ref(false)
const busyId = ref<number>()
const createOpen = ref(false)
const resetOpen = ref(false)
const selected = ref<UserProfile>()
const createForm = reactive({ username: '', password: '' })
const resetForm = reactive({ password: '' })
const statusOptions = [{ label: '已启用', value: 'ACTIVE' }, { label: '已停用', value: 'DISABLED' }]
const columns = [
  { title: '用户名', dataIndex: 'username', key: 'username' },
  { title: '状态', key: 'status' },
  { title: '密码状态', key: 'mustChangePassword' },
  { title: '创建时间', key: 'createdAt' },
  { title: '操作', key: 'actions' },
]
function formatDate(value: string) { return value ? dayjs(value).format('YYYY-MM-DD HH:mm') : '—' }
let requestSequence = 0
async function fetchUsers() {
  const sequence = ++requestSequence
  loading.value = true
  try {
    const data = await request.get<never, { records: UserProfile[]; total: number }>('/admin/users', { params: { page: page.value, pageSize: pageSize.value, keyword: keyword.value.trim(), status: status.value } })
    if (sequence !== requestSequence) return
    users.value = data.records
    total.value = data.total
  } catch { /* The shared interceptor presents request errors. */ }
  finally { if (sequence === requestSequence) loading.value = false }
}
function search() { page.value = 1; void fetchUsers() }
function changePage(pagination: { current?: number; pageSize?: number }) { page.value = pagination.current ?? 1; pageSize.value = pagination.pageSize ?? 20; void fetchUsers() }
function resetForms() { createForm.username = ''; createForm.password = ''; resetForm.password = '' }
function openCreate() { resetForms(); createOpen.value = true }
function openReset(user: UserProfile) { resetForms(); selected.value = user; resetOpen.value = true }
async function create() {
  saving.value = true
  try { await request.post('/admin/users', { username: createForm.username.trim(), password: createForm.password }); createOpen.value = false; resetForms(); message.success('用户已创建，请将初始密码交给该用户'); search() }
  catch { /* Keep form open for correction. */ }
  finally { saving.value = false }
}
async function resetPassword() {
  if (!selected.value) return
  saving.value = true
  try { await request.post(`/admin/users/${selected.value.id}/reset-password`, { password: resetForm.password }); resetOpen.value = false; resetForms(); message.success('密码已重置，请将临时密码交给该用户'); await fetchUsers() }
  catch { /* Keep form open for correction. */ }
  finally { saving.value = false }
}
async function toggleStatus(user: UserProfile) {
  busyId.value = user.id
  try { await request.put(`/admin/users/${user.id}/status`, { status: user.status === 'ACTIVE' ? 'DISABLED' : 'ACTIVE' }); message.success('用户状态已更新'); await fetchUsers() }
  catch { /* The shared interceptor presents request errors. */ }
  finally { busyId.value = undefined }
}
async function remove(user: UserProfile) {
  busyId.value = user.id
  try { await request.delete(`/admin/users/${user.id}`); if (users.value.length === 1 && page.value > 1) page.value--; message.success('用户已删除'); await fetchUsers() }
  catch { /* The shared interceptor presents request errors. */ }
  finally { busyId.value = undefined }
}
onMounted(fetchUsers)
</script>
