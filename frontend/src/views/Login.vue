<template>
  <main class="auth-page">
    <a-card class="auth-card" :bordered="false">
      <div class="eyebrow">MONEYDAY · 我的云端账本</div>
      <h1>欢迎回来</h1>
      <p class="auth-description">登录后，让每一笔都有方向。</p>
      <a-alert v-if="session.token" type="warning" show-icon message="暂时无法验证会话，请检查网络后重试，或重新登录。" class="auth-notice" />
      <a-form layout="vertical" :model="form" @finish="login">
        <a-form-item label="用户名" name="username" :rules="[{ required: true, whitespace: true, message: '请输入用户名' }]">
          <a-input v-model:value="form.username" autocomplete="username" placeholder="请输入管理员为你创建的用户名" :maxlength="64" />
        </a-form-item>
        <a-form-item label="密码" name="password" :rules="[{ required: true, message: '请输入密码' }]">
          <a-input-password v-model:value="form.password" autocomplete="current-password" placeholder="请输入密码" />
        </a-form-item>
        <a-button type="primary" html-type="submit" block :loading="loading">登录</a-button>
      </a-form>
      <a-button v-if="session.token" type="link" block @click="router.replace('/')">重试验证当前会话</a-button>
      <p class="auth-footnote">暂不开放注册，请联系管理员创建账户或重置密码。</p>
    </a-card>
  </main>
</template>
<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import request from '../utils/request'
import { session, setSession } from '../auth/session'
import type { LoginResult } from '../auth/session'
const router = useRouter()
const form = reactive({ username: '', password: '' })
const loading = ref(false)
async function login() {
  loading.value = true
  try {
    const result = await request.post<never, LoginResult>('/user/login', { username: form.username.trim(), password: form.password })
    setSession(result)
    form.password = ''
    await router.replace(result.user.mustChangePassword ? '/change-password' : '/')
  } catch { /* The shared interceptor presents request errors. */ }
  finally { loading.value = false }
}
</script>
