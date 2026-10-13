import { cycleService } from './cycleService';
import { liabilityService } from './liabilityService';
import { wishlistService } from './wishlistService';
import { todoService } from './todoService';

export const inspectionService = {
  async executeAllChecks(): Promise<void> {
    try {
      // 1. 周期自动滚动推算
      const template = await cycleService.getDefaultTemplate();
      if (template) {
        const { startDate, endDate } = cycleService.getCurrentCycleDates(template.startDay || 1);
        const record = await cycleService.getOrCreateSnapshot(startDate, endDate);
        if (record && record.fixedItems) {
          const pendingCount = record.fixedItems.filter(it => it.type !== 'DEPOSIT' && !it.isBooked).length;
          if (pendingCount > 0) {
            const title = `【新周期账单提醒】${startDate} 至 ${endDate}`;
            const content = `新周期已开启，共有 ${pendingCount} 笔固定收支待确认，请前往周期预算表核对。`;
            await todoService.createTodoIfNotExists('CYCLE_FIXED_ITEMS', title, content, String(record.id));
          }
        }
      }

      // 2. 分期智能到期扣款与逾期待办巡检
      await liabilityService.checkAndExecuteDueRepayments();

      // 3. 心愿达成巡检
      await wishlistService.checkWishlistMilestones();
    } catch (e) {
      console.warn('[Inspection] 开机自检执行告警:', e);
    }
  }
};
