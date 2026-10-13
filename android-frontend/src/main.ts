import { createApp } from 'vue';
import App from './App.vue';
import router from './router';

import Vant from 'vant';
// 引入 Vant 全局样式
import 'vant/lib/index.css';

const app = createApp(App);

app.use(Vant);
app.use(router);
app.mount('#app');
