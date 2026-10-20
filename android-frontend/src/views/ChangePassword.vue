<template>
  <main>
    <van-nav-bar title="修改密码" :left-arrow="!session.user?.mustChangePassword" @click-left="router.back()" />
    <van-notice-bar v-if="session.user?.mustChangePassword" wrapable :scrollable="false" text="首次登录或密码重置后，请先修改密码，再进入账本。" />
    <van-form @submit="submit">
      <van-cell-group inset style="margin-top: 24px">
        <van-field v-model="oldPassword" type="password" label="原密码" autocomplete="current-password" :rules="[{ required: true, message: '请输入原密码' }]" />
        <van-field v-model="newPassword" type="password" label="新密码" autocomplete="new-password" :rules="[{ validator: validPassword, message: '至少8位，UTF-8长度不超过72字节' }]" />
        <van-field v-model="confirmPassword" type="password" label="确认密码" autocomplete="new-password" :rules="[{ validator: (v: string) => v === newPassword && !!v, message: '两次新密码不一致' }]" />
      </van-cell-group>
      <div style="margin: 24px 16px"><van-button block round type="primary" native-type="submit" :loading="loading">保存并重新登录</van-button></div>
    </van-form>
    <van-cell v-if="session.user?.mustChangePassword" title="退出登录" is-link @click="logout" />
  </main>
</template>
<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { showToast } from 'vant';
import { session, validPassword } from '../state/session';
import { authService } from '../services/authService';
const oldPassword = ref('');
const newPassword = ref('');
const confirmPassword = ref('');
const loading = ref(false);
const router = useRouter();
async function submit() {
  if (loading.value) return;
  loading.value = true;
  try {
    await authService.changePassword(oldPassword.value, newPassword.value);
    showToast('密码已修改，请重新登录');
    await router.replace('/login');
  } catch { /* Shared request displays the error. */ }
  finally { loading.value = false; }
}
async function logout() { try { await authService.logout(); } finally { await router.replace('/login'); } }
</script>
