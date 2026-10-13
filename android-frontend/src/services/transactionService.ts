import { dbManager } from '../db';
import { accountService } from './accountService';

export interface Transaction {
  id?: number;
  type: number; // 1=收入, 2=支出, 3=转账
  amount: number;
  transactionDate: string;
  categoryId?: number | null;
  accountId: number;
  toAccountId?: number | null;
  remark?: string;
  liabilityId?: number | null;
  createdAt?: string;
}

export const transactionService = {
  async getAllTransactions(): Promise<Transaction[]> {
    const rows = await dbManager.query<any>(
      'SELECT * FROM transaction_record ORDER BY transaction_date DESC, id DESC'
    );
    return rows.map(r => ({
      id: r.id,
      type: Number(r.type),
      amount: Number(r.amount),
      transactionDate: r.transaction_date,
      categoryId: r.category_id,
      accountId: r.account_id,
      toAccountId: r.to_account_id,
      remark: r.remark,
      liabilityId: r.liability_id,
      createdAt: r.created_at
    }));
  },

  async getTransactionById(id: number): Promise<Transaction | null> {
    const rows = await dbManager.query<any>('SELECT * FROM transaction_record WHERE id = ?', [id]);
    if (rows.length === 0) return null;
    const r = rows[0];
    return {
      id: r.id,
      type: Number(r.type),
      amount: Number(r.amount),
      transactionDate: r.transaction_date,
      categoryId: r.category_id,
      accountId: r.account_id,
      toAccountId: r.to_account_id,
      remark: r.remark,
      liabilityId: r.liability_id,
      createdAt: r.created_at
    };
  },

  async addTransaction(tx: Transaction): Promise<number> {
    const res = await dbManager.run(
      `INSERT INTO transaction_record 
       (type, amount, transaction_date, category_id, account_id, to_account_id, remark, liability_id) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        tx.type,
        tx.amount,
        tx.transactionDate,
        tx.categoryId || null,
        tx.accountId,
        tx.toAccountId || null,
        tx.remark || null,
        tx.liabilityId || null
      ]
    );

    const insertedId = res.lastId || 0;

    // 更新账户余额
    await this.applyTransactionToAccount(tx, false);

    return insertedId;
  },

  async deleteTransaction(id: number): Promise<void> {
    const oldTx = await this.getTransactionById(id);
    if (!oldTx) return;

    // 回滚账户余额
    await this.applyTransactionToAccount(oldTx, true);

    // 删除记录
    await dbManager.run('DELETE FROM transaction_record WHERE id = ?', [id]);

    // 检查并联动重置周期快照中的固定项状态
    const cycleRows = await dbManager.query<any>('SELECT * FROM cycle_record');
    for (const record of cycleRows) {
      if (record.fixed_items) {
        try {
          const items: any[] = JSON.parse(record.fixed_items);
          let modified = false;
          for (const item of items) {
            if (item.transactionId === id) {
              item.isBooked = false;
              item.transactionId = null;
              modified = true;
            }
          }
          if (modified) {
            await dbManager.run(
              'UPDATE cycle_record SET fixed_items = ? WHERE id = ?',
              [JSON.stringify(items), record.id]
            );
          }
        } catch (ignored) {}
      }
    }
  },

  async applyTransactionToAccount(tx: Transaction, isRevert: boolean): Promise<void> {
    let amt = Number(tx.amount || 0);
    if (isRevert) {
      amt = -amt;
    }

    if (tx.type === 1) {
      // 收入: +amt
      await accountService.updateBalance(tx.accountId, amt);
    } else if (tx.type === 2) {
      // 支出: -amt
      await accountService.updateBalance(tx.accountId, -amt);
    } else if (tx.type === 3) {
      // 转账: 转出 -amt, 转入 +amt
      await accountService.updateBalance(tx.accountId, -amt);
      if (tx.toAccountId) {
        await accountService.updateBalance(tx.toAccountId, amt);
      }
    }
  }
};
