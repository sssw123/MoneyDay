<template>
  <main class="auth-page">
    <a-card class="auth-card" :bordered="false">
      <div class="eyebrow">MONEYDAY · 账户安全</div>
      <h1>{{ session.user?.mustChangePassword ? '设置你的新密码' : '修改密码' }}</h1>
      <p class="auth-description">{{ session.user?.mustChangePassword ? '首次登录或密码被重置后，请先修改密码再使用账本。' : '修改后，所有设备的会话都会退出，需要重新登录。' }}</p>
      <a-form layout="vertical" :model="form" @finish="changePassword">
        <a-form-item label="当前密码" name="oldPassword" :rules="[{ required: true, message: '请输入当前密码' }]">
          <a-input-password v-model:value="form.oldPassword" autocomplete="current-password" />
        </a-form-item>
        <a-form-item label="新密码" name="newPassword" :rules="[passwordRule]" help="至少 8 位，UTF-8 编码不超过 72 字节">
          <a-input-password v-model:value="form.newPassword" autocomplete="new-password" />
        </a-form-item>
        <a-form-item label="确认新密码" name="confirmPassword" :rules="[{ validator: confirmPassword }]">
          <a-input-password v-model:value="form.confirmPassword" autocomplete="new-password" />
        </a-form-item>
        <a-button type="primary" html-type="submit" block :loading="loading">确认修改并重新登录</a-button>
      </a-form>
      <div class="auth-secondary-actions">
        <a-button v-if="!session.user?.mustChangePassword" type="link" @click="router.push('/')">返回账本</a-button>
        <a-button type="link" @click="exit">退出登录</a-button>
      </div>
    </a-card>
  </main>
</template>
<script setup lang="ts">
import { reactive, ref } from 'vue'
import { message } from 'ant-design-vue'
import { useRouter } from 'vue-router'
import request, { logoutSession } from '../utils/request'
import { session, clearSession, passwordRule } from '../auth/session'
const router = useRouter()
const form = reactive({ oldPassword: '', newPassword: '', confirmPassword: '' })
const loading = ref(false)
async function confirmPassword(_: unknown, value: string) {
  if (!value || value !== form.newPassword) throw new Error('两次输入的新密码不一致')
  if (value === form.oldPassword) throw new Error('新密码不能与当前密码相同')
}
async function changePassword() {
  loading.value = true
  try {
    await request.put('/user/password', { oldPassword: form.oldPassword, newPassword: form.newPassword })
    clearSession()
    form.oldPassword = form.newPassword = form.confirmPassword = ''
    message.success('密码已修改，请重新登录')
    await router.replace('/login')
  } catch { /* The shared interceptor presents request errors. */ }
  finally { loading.value = false }
}
async function exit() { const pending = logoutSession(); await router.replace('/login'); await pending }
</script>
