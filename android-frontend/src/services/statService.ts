import { dbManager } from '../db';
import { cycleService } from './cycleService';

export interface StatDTO {
  totalAssets: number;
  totalLiabilities: number;
  totalLiabilityAmount?: number;
  availableAssets: number;
  availableNetAssets?: number;
  currentIncome: number;
  currentExpense: number;
  currentFixedDeposit: number;
  currentBalance: number;
  currentFinalBalance: number;
  cumulativeBalance: number;
  categoryExpenses: Array<{ name: string; value: number }>;
}

export const statService = {
  async getStats(): Promise<StatDTO> {
    // 1. 总资产
    const accRows = await dbManager.query<any>('SELECT COALESCE(SUM(current_balance), 0) as total FROM account');
    const totalAssets = Number(accRows[0]?.total || 0);

    // 2. 总未还负债
    const liabRows = await dbManager.query<any>(
      "SELECT COALESCE(SUM((total_periods - current_period) * period_amount), 0) as total FROM liability WHERE status = 'REPAYING'"
    );
    const totalLiabilities = Number(liabRows[0]?.total || 0);

    // 可用净资产
    const availableAssets = totalAssets - totalLiabilities;

    // 3. 当前周期起止日
    const template = await cycleService.getDefaultTemplate();
    const { startDate, endDate } = cycleService.getCurrentCycleDates(template?.startDay || 1);

    // 4. 当期收入与支出
    const incRows = await dbManager.query<any>(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transaction_record WHERE type = 1 AND transaction_date BETWEEN ? AND ?',
      [startDate, endDate]
    );
    const expRows = await dbManager.query<any>(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transaction_record WHERE type = 2 AND transaction_date BETWEEN ? AND ?',
      [startDate, endDate]
    );

    const currentIncome = Number(incRows[0]?.total || 0);
    const currentExpense = Number(expRows[0]?.total || 0);

    // 当期固定存款
    const snapshot = await cycleService.getOrCreateSnapshot(startDate, endDate);
    let currentFixedDeposit = 0;
    if (snapshot.fixedItems) {
      for (const it of snapshot.fixedItems) {
        if (it.type === 'DEPOSIT' && it.amount) {
          currentFixedDeposit += Number(it.amount);
        }
      }
    }

    const currentBalance = currentIncome - currentFixedDeposit - currentExpense;
    const currentFinalBalance = currentFixedDeposit + currentBalance;

    // 5. 累计结余
    const cumulativeBalance = await cycleService.getTotalCumulativeBalance();

    // 6. 分类支出统计
    const catRows = await dbManager.query<any>(
      `SELECT COALESCE(c.name, '未分类') as name, SUM(t.amount) as value 
       FROM transaction_record t 
       LEFT JOIN category c ON t.category_id = c.id 
       WHERE t.type = 2 AND t.transaction_date BETWEEN ? AND ? 
       GROUP BY t.category_id, c.name`,
      [startDate, endDate]
    );

    const categoryExpenses = catRows.map(r => ({
      name: r.name,
      value: Number(r.value || 0)
    }));

    return {
      totalAssets,
      totalLiabilities,
      totalLiabilityAmount: totalLiabilities,
      availableAssets,
      availableNetAssets: availableAssets,
      currentIncome,
      currentExpense,
      currentFixedDeposit,
      currentBalance,
      currentFinalBalance,
      cumulativeBalance,
      categoryExpenses
    };
  }
};
