import { dbManager } from '../db';

export interface Account {
  id: number;
  name: string;
  type: string;
  initialBalance: number;
  currentBalance: number;
  createdAt?: string;
}

export const accountService = {
  async getAccounts(): Promise<Account[]> {
    const rows = await dbManager.query<any>('SELECT * FROM account ORDER BY id ASC');
    return rows.map(r => ({
      id: r.id,
      name: r.name,
      type: r.type,
      initialBalance: Number(r.initial_balance || 0),
      currentBalance: Number(r.current_balance || 0),
      createdAt: r.created_at
    }));
  },

  async getAccountById(id: number): Promise<Account | null> {
    const rows = await dbManager.query<any>('SELECT * FROM account WHERE id = ?', [id]);
    if (rows.length === 0) return null;
    const r = rows[0];
    return {
      id: r.id,
      name: r.name,
      type: r.type,
      initialBalance: Number(r.initial_balance || 0),
      currentBalance: Number(r.current_balance || 0),
      createdAt: r.created_at
    };
  },

  async addAccount(account: Partial<Account>): Promise<number> {
    const initBal = Number(account.initialBalance || 0);
    const curBal = Number(account.currentBalance ?? initBal);
    const res = await dbManager.run(
      'INSERT INTO account (name, type, initial_balance, current_balance) VALUES (?, ?, ?, ?)',
      [account.name, account.type || 'BANK', initBal, curBal]
    );
    return res.lastId || 0;
  },

  async updateBalance(id: number, delta: number): Promise<void> {
    await dbManager.run(
      'UPDATE account SET current_balance = current_balance + ? WHERE id = ?',
      [delta, id]
    );
  }
};
