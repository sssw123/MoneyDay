// Request tests inspect effects without mounting UI or requiring a browser.
export const notifications: unknown[] = [];
export function showToast(value: unknown) { notifications.push(value); }
