import dayjs from 'dayjs';
import { dbManager } from '../db';
import { transactionService } from './transactionService';

export interface FixedItem {
  id: string;
  name: string;
  type: 'INCOME' | 'EXPENSE' | 'DEPOSIT';
  amount: number;
  expectedDay?: number;
  isBooked?: boolean;
  transactionId?: number | null;
  accountId?: number | null;
  liabilityId?: number | null;
}

export interface CycleTemplate {
  id: number;
  name: string;
  startDay: number;
  isDefault: number;
  fixedItems: FixedItem[];
}

export interface CycleRecord {
  id: number;
  cycleStartDate: string;
  cycleEndDate: string;
  fixedItems: FixedItem[];
  income?: number;
  expense?: number;
  balance?: number;
  createdAt?: string;
}

export const cycleService = {
  async getCycleTemplates(): Promise<CycleTemplate[]> {
    const rows = await dbManager.query<any>('SELECT * FROM cycle_template ORDER BY id ASC');
    return rows.map(r => ({
      id: r.id,
      name: r.name,
      startDay: Number(r.start_day || 1),
      isDefault: Number(r.is_default || 0),
      fixedItems: r.fixed_items ? JSON.parse(r.fixed_items) : []
    }));
  },

  async getDefaultTemplate(): Promise<CycleTemplate | null> {
    const rows = await dbManager.query<any>(
      'SELECT * FROM cycle_template WHERE is_default = 1 LIMIT 1'
    );
    if (rows.length === 0) {
      const all = await this.getCycleTemplates();
      return all[0] || null;
    }
    const r = rows[0];
    return {
      id: r.id,
      name: r.name,
      startDay: Number(r.start_day || 1),
      isDefault: Number(r.is_default || 0),
      fixedItems: r.fixed_items ? JSON.parse(r.fixed_items) : []
    };
  },

  async saveCycleTemplate(template: CycleTemplate): Promise<void> {
    await dbManager.run(
      'UPDATE cycle_template SET name = ?, start_day = ?, fixed_items = ? WHERE id = ?',
      [template.name, template.startDay, JSON.stringify(template.fixedItems || []), template.id]
    );
  },

  getCurrentCycleDates(startDay: number = 1): { startDate: string; endDate: string } {
    const today = dayjs();
    const daysInMonth = today.daysInMonth();
    const actualStartDay = Math.min(startDay, daysInMonth);

    let start = today;
    if (today.date() >= actualStartDay) {
      start = today.date(actualStartDay);
    } else {
      const lastMonth = today.subtract(1, 'month');
      start = lastMonth.date(Math.min(startDay, lastMonth.daysInMonth()));
    }

    const nextMonth = start.add(1, 'month');
    const end = nextMonth.date(Math.min(startDay, nextMonth.daysInMonth())).subtract(1, 'day');

    return {
      startDate: start.format('YYYY-MM-DD'),
      endDate: end.format('YYYY-MM-DD')
    };
  },

  async getOrCreateSnapshot(startDate: string, endDate: string): Promise<CycleRecord> {
    const rows = await dbManager.query<any>(
      'SELECT * FROM cycle_record WHERE cycle_start_date = ? AND cycle_end_date = ? LIMIT 1',
      [startDate, endDate]
    );

    if (rows.length > 0) {
      const r = rows[0];
      return {
        id: r.id,
        cycleStartDate: r.cycle_start_date,
        cycleEndDate: r.cycle_end_date,
        fixedItems: r.fixed_items ? JSON.parse(r.fixed_items) : []
      };
    }

    // 从模板和分期自动生成快照
    const template = await this.getDefaultTemplate();
    const items: FixedItem[] = [];

    if (template && template.fixedItems) {
      for (const tItem of template.fixedItems) {
        items.push({
          ...tItem,
          isBooked: false,
          transactionId: null
        });
      }
    }

    // 联动自动生成还款中的分期固定支出
    const liabilities = await dbManager.query<any>(
      "SELECT * FROM liability WHERE status = 'REPAYING' AND auto_cycle_fixed_expense = 1"
    );
    for (const l of liabilities) {
      items.push({
        id: 'liab_' + l.id,
        name: `分期还款: ${l.name}`,
        type: 'EXPENSE',
        amount: Number(l.period_amount || 0),
        expectedDay: Number(l.repayment_day || 1),
        isBooked: false,
        transactionId: null,
        liabilityId: l.id,
        accountId: l.default_account_id
      });
    }

    const res = await dbManager.run(
      'INSERT INTO cycle_record (cycle_start_date, cycle_end_date, fixed_items) VALUES (?, ?, ?)',
      [startDate, endDate, JSON.stringify(items)]
    );

    return {
      id: res.lastId || 0,
      cycleStartDate: startDate,
      cycleEndDate: endDate,
      fixedItems: items
    };
  },

  async getRecentCycles(limit: number = 6): Promise<CycleRecord[]> {
    const template = await this.getDefaultTemplate();
    const dates = this.getCurrentCycleDates(template?.startDay || 1);
    // 确保当前周期快照存在
    await this.getOrCreateSnapshot(dates.startDate, dates.endDate);

    const rows = await dbManager.query<any>(
      'SELECT * FROM cycle_record ORDER BY cycle_start_date DESC LIMIT ?',
      [limit]
    );

    const results: CycleRecord[] = [];
    for (const r of rows) {
      const sDate = r.cycle_start_date;
      const eDate = r.cycle_end_date;

      // 统计当期流水收入与支出
      const incRows = await dbManager.query<any>(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transaction_record WHERE type = 1 AND transaction_date BETWEEN ? AND ?',
        [sDate, eDate]
      );
      const expRows = await dbManager.query<any>(
        'SELECT COALESCE(SUM(amount), 0) as total FROM transaction_record WHERE type = 2 AND transaction_date BETWEEN ? AND ?',
        [sDate, eDate]
      );

      const income = Number(incRows[0]?.total || 0);
      const expense = Number(expRows[0]?.total || 0);

      const fixedItems: FixedItem[] = r.fixed_items ? JSON.parse(r.fixed_items) : [];
      let fixedDeposit = 0;
      for (const item of fixedItems) {
        if (item.type === 'DEPOSIT' && item.amount) {
          fixedDeposit += Number(item.amount);
        }
      }

      const balance = income - fixedDeposit - expense;

      results.push({
        id: r.id,
        cycleStartDate: sDate,
        cycleEndDate: eDate,
        fixedItems,
        income,
        expense,
        balance
      });
    }

    return results;
  },

  async bookItem(cycleId: number, itemId: string, accountId: number, amount: number, date: string): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM cycle_record WHERE id = ?', [cycleId]);
    if (rows.length === 0) throw new Error('Cycle record not found');
    const r = rows[0];
    const items: FixedItem[] = r.fixed_items ? JSON.parse(r.fixed_items) : [];

    const targetItem = items.find(it => it.id === itemId);
    if (!targetItem) throw new Error('Item not found in cycle');

    // 生成记账流水
    const txType = targetItem.type === 'INCOME' ? 1 : 2;
    const txId = await transactionService.addTransaction({
      type: txType,
      amount: amount,
      transactionDate: date,
      accountId: accountId,
      remark: `【周期固定${targetItem.name}】`,
      liabilityId: targetItem.liabilityId || null
    });

    targetItem.isBooked = true;
    targetItem.transactionId = txId;
    targetItem.amount = amount;
    targetItem.accountId = accountId;

    await dbManager.run(
      'UPDATE cycle_record SET fixed_items = ? WHERE id = ?',
      [JSON.stringify(items), cycleId]
    );
  },

  async unbookItem(cycleId: number, itemId: string): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM cycle_record WHERE id = ?', [cycleId]);
    if (rows.length === 0) return;
    const r = rows[0];
    const items: FixedItem[] = r.fixed_items ? JSON.parse(r.fixed_items) : [];

    const targetItem = items.find(it => it.id === itemId);
    if (!targetItem) return;

    if (targetItem.transactionId) {
      await transactionService.deleteTransaction(targetItem.transactionId);
    }

    targetItem.isBooked = false;
    targetItem.transactionId = null;

    await dbManager.run(
      'UPDATE cycle_record SET fixed_items = ? WHERE id = ?',
      [JSON.stringify(items), cycleId]
    );
  },

  async getTotalCumulativeBalance(): Promise<number> {
    const cycles = await this.getRecentCycles(24);
    let total = 0;
    for (const c of cycles) {
      total += Number(c.balance || 0);
    }
    return total;
  }
};
