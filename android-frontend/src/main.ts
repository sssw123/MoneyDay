import { createApp } from 'vue';
import App from './App.vue';
import router from './router';

import Vant from 'vant';
// 引入 Vant 全局样式
import 'vant/lib/index.css';
import { dbManager } from './db';

const bootstrap = async () => {
  try {
    await dbManager.init();
  } catch (err) {
    console.error('Database initialization failed:', err);
  }

  const app = createApp(App);
  app.use(Vant);
  app.use(router);
  app.mount('#app');
};

bootstrap();
