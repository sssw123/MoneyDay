import dayjs from 'dayjs';
import { dbManager } from '../db';
import { cycleService } from './cycleService';
import { transactionService } from './transactionService';
import { todoService } from './todoService';

export interface Wishlist {
  id: number;
  name: string;
  targetAmount: number;
  deadline?: string | null;
  startDate: string;
  isRealized: number; // 0=心愿中, 1=已实现
  createdAt?: string;

  // VO 动态计算属性
  progress?: number;
  estimatedCompletionDate?: string;
  isEstimatedFallback?: boolean;
  estimatedReason?: string;
}

export const wishlistService = {
  async getAllWishlists(): Promise<Wishlist[]> {
    const rows = await dbManager.query<any>('SELECT * FROM wishlist ORDER BY id ASC');
    if (rows.length === 0) return [];

    const cumulativeBalance = await cycleService.getTotalCumulativeBalance();
    const recentCycles = await cycleService.getRecentCycles(12);

    // 计算历史实际平均结余
    let historicalSum = 0;
    let historicalCount = 0;
    const today = dayjs();
    for (const c of recentCycles) {
      if (dayjs(c.cycleEndDate).isBefore(today, 'day')) {
        historicalSum += Number(c.balance || 0);
        historicalCount++;
      }
    }
    const avgHistoricalBalance = historicalCount > 0 ? historicalSum / historicalCount : null;

    // 解析默认模板基准结余
    const template = await cycleService.getDefaultTemplate();
    let templateFixedIncome = 0;
    let templateFixedExpense = 0;
    let templateFixedDeposit = 0;
    if (template && template.fixedItems) {
      for (const item of template.fixedItems) {
        const amt = Number(item.amount || 0);
        if (item.type === 'INCOME') templateFixedIncome += amt;
        if (item.type === 'EXPENSE') templateFixedExpense += amt;
        if (item.type === 'DEPOSIT') templateFixedDeposit += amt;
      }
    }
    const templateBaseSurplus = templateFixedIncome - templateFixedExpense - templateFixedDeposit;

    return rows.map(r => {
      const targetAmt = Number(r.target_amount || 0);
      const isRealized = Number(r.is_realized || 0);

      const progress = targetAmt > 0
        ? Math.min(100, Math.max(0, Math.round((cumulativeBalance / targetAmt) * 100)))
        : 0;

      let estDate = '无法预估';
      let isFallback = false;
      let estReason = '';

      if (isRealized === 1) {
        estDate = '-';
      } else if (cumulativeBalance >= targetAmt) {
        estDate = '当前可实现';
        estReason = '当前累计结余充足，可随时兑现';
      } else {
        const remainingAmt = targetAmt - cumulativeBalance;
        let speed = 0;

        if (avgHistoricalBalance !== null && avgHistoricalBalance > 0) {
          speed = avgHistoricalBalance;
          estReason = `基于近${historicalCount}期平均月结余 (¥${speed.toFixed(2)}) 测算`;
        } else if (templateBaseSurplus > 0) {
          speed = templateBaseSurplus;
          isFallback = true;
          estReason = `历史结余无盈余，已降级为模板预算月结余 (¥${speed.toFixed(2)}) 测算`;
        }

        if (speed > 0) {
          const monthsNeeded = Math.ceil(remainingAmt / speed);
          estDate = dayjs().add(monthsNeeded, 'month').format('YYYY-MM');
        } else {
          estDate = '无法预估';
          estReason = '存钱速度无盈余，无法预估达成时间';
        }
      }

      return {
        id: r.id,
        name: r.name,
        targetAmount: targetAmt,
        deadline: r.deadline,
        startDate: r.start_date,
        isRealized,
        createdAt: r.created_at,
        progress,
        estimatedCompletionDate: estDate,
        isEstimatedFallback: isFallback,
        estimatedReason: estReason
      };
    });
  },

  async addWishlist(wishlist: Partial<Wishlist>): Promise<number> {
    const res = await dbManager.run(
      'INSERT INTO wishlist (name, target_amount, deadline, start_date, is_realized) VALUES (?, ?, ?, ?, ?)',
      [
        wishlist.name,
        wishlist.targetAmount || 0,
        wishlist.deadline || null,
        wishlist.startDate || dayjs().format('YYYY-MM-DD'),
        0
      ]
    );
    return res.lastId || 0;
  },

  async updateWishlist(wishlist: Wishlist): Promise<void> {
    await dbManager.run(
      'UPDATE wishlist SET name = ?, target_amount = ?, deadline = ? WHERE id = ?',
      [wishlist.name, wishlist.targetAmount, wishlist.deadline || null, wishlist.id]
    );
  },

  async deleteWishlist(id: number): Promise<void> {
    await dbManager.run('DELETE FROM wishlist WHERE id = ?', [id]);
    await todoService.resolveTodoByBiz('WISHLIST_REACHED', String(id));
  },

  async realizeWishlist(id: number, accountId: number): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM wishlist WHERE id = ?', [id]);
    if (rows.length === 0) throw new Error('Wishlist not found');
    const w = rows[0];

    // 查询或匹配【目标】分类
    const catRows = await dbManager.query<any>("SELECT id FROM category WHERE name = '目标' LIMIT 1");
    const catId = catRows[0]?.id || null;

    // 生成支出流水
    await transactionService.addTransaction({
      type: 2,
      amount: Number(w.target_amount || 0),
      transactionDate: dayjs().format('YYYY-MM-DD'),
      categoryId: catId,
      accountId: accountId,
      remark: `【心愿兑现】${w.name}`
    });

    await dbManager.run('UPDATE wishlist SET is_realized = 1 WHERE id = ?', [id]);
    await todoService.resolveTodoByBiz('WISHLIST_REACHED', String(id));
  },

  async unrealizeWishlist(id: number): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM wishlist WHERE id = ?', [id]);
    if (rows.length === 0) return;
    const w = rows[0];

    // 查找并删除当时生成的兑现支出流水
    const txRows = await dbManager.query<any>(
      "SELECT id FROM transaction_record WHERE type = 2 AND remark = ? ORDER BY id DESC LIMIT 1",
      [`【心愿兑现】${w.name}`]
    );
    if (txRows.length > 0) {
      await transactionService.deleteTransaction(txRows[0].id);
    }

    await dbManager.run('UPDATE wishlist SET is_realized = 0 WHERE id = ?', [id]);
  },

  async checkWishlistMilestones(): Promise<void> {
    const cumulativeBalance = await cycleService.getTotalCumulativeBalance();
    const unfulfilled = await dbManager.query<any>('SELECT * FROM wishlist WHERE is_realized = 0');

    for (const w of unfulfilled) {
      const amt = Number(w.target_amount || 0);
      if (amt > 0 && cumulativeBalance >= amt) {
        const title = `【心愿达成提醒】${w.name}`;
        const content = `累计结余已达 ¥${cumulativeBalance.toFixed(2)}，已覆盖心愿所需 ¥${amt.toFixed(2)}，可随时兑现！`;
        await todoService.createTodoIfNotExists('WISHLIST_REACHED', title, content, String(w.id));
      }
    }
  }
};
