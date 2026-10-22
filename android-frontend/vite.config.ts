import { defineConfig, loadEnv } from 'vite';
import vue from '@vitejs/plugin-vue';
import { resolve } from 'path';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  const apiUrl = process.env.VITE_API_BASE_URL || env.VITE_API_BASE_URL;
  if (mode.startsWith('android-') && !apiUrl) throw new Error('Android 打包必须设置 VITE_API_BASE_URL');
  if (mode === 'android-release' && !apiUrl?.startsWith('https://')) throw new Error('Android 正式包的 API 必须使用 HTTPS');
  return {
    plugins: [vue()],
    resolve: { alias: { '@': resolve(__dirname, 'src') } },
    server: {
      host: '0.0.0.0', port: 5174,
      proxy: { '/api': { target: 'http://localhost:8080', changeOrigin: true } },
    },
  };
});
