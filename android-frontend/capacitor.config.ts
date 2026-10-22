import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.moneyday.app',
  appName: 'MoneyDay',
  webDir: 'dist',
  android: { allowMixedContent: process.env.MONEYDAY_ANDROID_DEBUG === 'true' },
  server: {
    androidScheme: 'https'
  }
};

export default config;
