<template>
  <main class="auth-page">
    <h1>MoneyDay</h1><p>登录云端账本，管理每一天的收支</p>
    <van-form @submit="submit">
      <van-cell-group inset>
        <van-field v-model="username" name="username" label="用户名" autocomplete="username" placeholder="管理员分配的用户名" :rules="[{ required: true, message: '请输入用户名' }]" />
        <van-field v-model="password" name="password" type="password" label="密码" autocomplete="current-password" :rules="[{ required: true, message: '请输入密码' }]" />
      </van-cell-group>
      <div class="auth-action"><van-button block round type="primary" native-type="submit" :loading="loading">登录</van-button></div>
    </van-form>
    <p>账户由管理员创建，暂不提供注册。</p>
  </main>
</template>
<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { authService } from '../services/authService';
const username = ref('');
const password = ref('');
const loading = ref(false);
const router = useRouter();
async function submit() {
  if (loading.value) return;
  loading.value = true;
  try {
    const { user } = await authService.login(username.value.trim(), password.value);
    password.value = '';
    await router.replace(user.mustChangePassword ? '/change-password' : '/');
  } catch { /* Shared request displays the error. */ }
  finally { loading.value = false; }
}
</script>
<style scoped>
.auth-page { padding: 64px 12px 24px; }
h1, p { text-align: center; }
h1 { color: #1989fa; }
p { color: #646566; font-size: 14px; margin-bottom: 28px; }
.auth-action { margin: 24px 16px; }
</style>
