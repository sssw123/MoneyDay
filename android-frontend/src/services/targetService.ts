import dayjs from 'dayjs';
import { dbManager } from '../db';
import { transactionService } from './transactionService';

export interface Target {
  id: number;
  name: string;
  targetAmount: number;
  deadline?: string | null;
  startDate: string;
  isRealized: number; // 0=未实现, 1=已实现
  createdAt?: string;
  progress?: number;
}

export const targetService = {
  async getAllTargets(): Promise<Target[]> {
    const rows = await dbManager.query<any>('SELECT * FROM target ORDER BY id ASC');
    // 查询总资产作为目标的参考累积
    const accRows = await dbManager.query<any>('SELECT COALESCE(SUM(current_balance), 0) as total FROM account');
    const totalAssets = Number(accRows[0]?.total || 0);

    return rows.map(r => {
      const amt = Number(r.target_amount || 0);
      const isRealized = Number(r.is_realized || 0);
      const progress = amt > 0
        ? Math.min(100, Math.max(0, Math.round((totalAssets / amt) * 100)))
        : 0;

      return {
        id: r.id,
        name: r.name,
        targetAmount: amt,
        deadline: r.deadline,
        startDate: r.start_date,
        isRealized,
        createdAt: r.created_at,
        progress: isRealized === 1 ? 100 : progress
      };
    });
  },

  async addTarget(target: Partial<Target>): Promise<number> {
    const res = await dbManager.run(
      'INSERT INTO target (name, target_amount, deadline, start_date, is_realized) VALUES (?, ?, ?, ?, ?)',
      [
        target.name,
        target.targetAmount || 0,
        target.deadline || null,
        target.startDate || dayjs().format('YYYY-MM-DD'),
        0
      ]
    );
    return res.lastId || 0;
  },

  async updateTarget(target: Target): Promise<void> {
    await dbManager.run(
      'UPDATE target SET name = ?, target_amount = ?, deadline = ? WHERE id = ?',
      [target.name, target.targetAmount, target.deadline || null, target.id]
    );
  },

  async deleteTarget(id: number): Promise<void> {
    await dbManager.run('DELETE FROM target WHERE id = ?', [id]);
  },

  async realizeTarget(id: number, accountId: number): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM target WHERE id = ?', [id]);
    if (rows.length === 0) throw new Error('Target not found');
    const t = rows[0];

    const catRows = await dbManager.query<any>("SELECT id FROM category WHERE name = '目标' LIMIT 1");
    const catId = catRows[0]?.id || null;

    // 生成支出流水
    await transactionService.addTransaction({
      type: 2,
      amount: Number(t.target_amount || 0),
      transactionDate: dayjs().format('YYYY-MM-DD'),
      categoryId: catId,
      accountId: accountId,
      remark: `【目标实现】${t.name}`
    });

    await dbManager.run('UPDATE target SET is_realized = 1 WHERE id = ?', [id]);
  },

  async unrealizeTarget(id: number): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM target WHERE id = ?', [id]);
    if (rows.length === 0) return;
    const t = rows[0];

    // 查找并删除当时生成的实现支出流水
    const txRows = await dbManager.query<any>(
      "SELECT id FROM transaction_record WHERE type = 2 AND remark = ? ORDER BY id DESC LIMIT 1",
      [`【目标实现】${t.name}`]
    );
    if (txRows.length > 0) {
      await transactionService.deleteTransaction(txRows[0].id);
    }

    await dbManager.run('UPDATE target SET is_realized = 0 WHERE id = ?', [id]);
  }
};
