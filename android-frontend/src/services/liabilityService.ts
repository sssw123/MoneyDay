import dayjs from 'dayjs';
import { dbManager } from '../db';
import { accountService } from './accountService';
import { transactionService } from './transactionService';
import { todoService } from './todoService';

export interface Liability {
  id: number;
  name: string;
  principal: number;
  totalAmount: number;
  totalPeriods: number;
  currentPeriod: number;
  periodAmount: number;
  rateType: string;
  interestRate: number;
  repaymentDay: number;
  nextRepaymentDate: string;
  defaultAccountId?: number | null;
  categoryId?: number | null;
  autoCycleFixedExpense: number;
  status: 'REPAYING' | 'SETTLED';
  startDate: string;
  settledAt?: string | null;
  createdAt?: string;

  // VO 扩展属性
  remainingPeriods?: number;
  remainingAmount?: number;
  progressPercent?: number;
  defaultAccountName?: string;
  categoryName?: string;
}

export const liabilityService = {
  async getAllLiabilities(): Promise<Liability[]> {
    try {
      await this.checkAndExecuteDueRepayments();
    } catch (e) {}

    const rows = await dbManager.query<any>(
      `SELECT l.*, a.name as default_account_name, c.name as category_name 
       FROM liability l 
       LEFT JOIN account a ON l.default_account_id = a.id 
       LEFT JOIN category c ON l.category_id = c.id 
       ORDER BY l.created_at DESC`
    );

    return rows.map(r => {
      const totalP = Number(r.total_periods || 1);
      const curP = Number(r.current_period || 0);
      const remainingP = Math.max(0, totalP - curP);
      const pAmt = Number(r.period_amount || 0);

      return {
        id: r.id,
        name: r.name,
        principal: Number(r.principal || 0),
        totalAmount: Number(r.total_amount || 0),
        totalPeriods: totalP,
        currentPeriod: curP,
        periodAmount: pAmt,
        rateType: r.rate_type || 'NONE',
        interestRate: Number(r.interest_rate || 0),
        repaymentDay: Number(r.repayment_day || 1),
        nextRepaymentDate: r.next_repayment_date,
        defaultAccountId: r.default_account_id,
        categoryId: r.category_id,
        autoCycleFixedExpense: Number(r.auto_cycle_fixed_expense ?? 1),
        status: r.status,
        startDate: r.start_date,
        settledAt: r.settled_at,
        createdAt: r.created_at,

        remainingPeriods: remainingP,
        remainingAmount: pAmt * remainingP,
        progressPercent: Math.min(100, Math.max(0, Math.round((curP * 100) / totalP))),
        defaultAccountName: r.default_account_name,
        categoryName: r.category_name
      };
    });
  },

  async getLiabilityById(id: number): Promise<Liability | null> {
    const rows = await dbManager.query<any>('SELECT * FROM liability WHERE id = ?', [id]);
    if (rows.length === 0) return null;
    const r = rows[0];
    const totalP = Number(r.total_periods || 1);
    const curP = Number(r.current_period || 0);
    return {
      id: r.id,
      name: r.name,
      principal: Number(r.principal || 0),
      totalAmount: Number(r.total_amount || 0),
      totalPeriods: totalP,
      currentPeriod: curP,
      periodAmount: Number(r.period_amount || 0),
      rateType: r.rate_type || 'NONE',
      interestRate: Number(r.interest_rate || 0),
      repaymentDay: Number(r.repayment_day || 1),
      nextRepaymentDate: r.next_repayment_date,
      defaultAccountId: r.default_account_id,
      categoryId: r.category_id,
      autoCycleFixedExpense: Number(r.auto_cycle_fixed_expense ?? 1),
      status: r.status,
      startDate: r.start_date,
      settledAt: r.settled_at,
      createdAt: r.created_at,
      remainingPeriods: Math.max(0, totalP - curP),
      remainingAmount: Number(r.period_amount || 0) * Math.max(0, totalP - curP)
    };
  },

  async addLiability(liability: Partial<Liability>): Promise<number> {
    const startDate = liability.startDate || dayjs().format('YYYY-MM-DD');
    const rDay = Number(liability.repaymentDay || 10);
    const totalP = Number(liability.totalPeriods || 1);
    const pAmt = Number(liability.periodAmount || 0);
    const principal = Number(liability.principal || pAmt * totalP);
    const totalAmt = Number(liability.totalAmount || pAmt * totalP);

    // 计算初次还款日
    const today = dayjs();
    let nextDate = today.date(Math.min(rDay, today.daysInMonth()));
    if (nextDate.isBefore(today, 'day')) {
      const nextMonth = today.add(1, 'month');
      nextDate = nextMonth.date(Math.min(rDay, nextMonth.daysInMonth()));
    }

    const res = await dbManager.run(
      `INSERT INTO liability (
        name, principal, total_amount, total_periods, current_period, period_amount,
        rate_type, interest_rate, repayment_day, next_repayment_date,
        default_account_id, category_id, auto_cycle_fixed_expense, status, start_date
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        liability.name,
        principal,
        totalAmt,
        totalP,
        0,
        pAmt,
        liability.rateType || 'NONE',
        liability.interestRate || 0,
        rDay,
        nextDate.format('YYYY-MM-DD'),
        liability.defaultAccountId || 1,
        liability.categoryId || 7,
        liability.autoCycleFixedExpense ?? 1,
        'REPAYING',
        startDate
      ]
    );

    return res.lastId || 0;
  },

  async deleteLiability(id: number): Promise<void> {
    await dbManager.run('DELETE FROM liability WHERE id = ?', [id]);
    await todoService.resolveTodoByBiz('LIABILITY_OVERDUE', String(id));
  },

  async repayPeriods(id: number, periods: number = 1, amount: number, accountId: number): Promise<void> {
    const liab = await this.getLiabilityById(id);
    if (!liab) throw new Error('Liability not found');
    if (liab.status === 'SETTLED') throw new Error('This liability is already settled');

    const newCurPeriod = liab.currentPeriod + periods;
    const isSettled = newCurPeriod >= liab.totalPeriods;

    // 生成支出记账流水
    await transactionService.addTransaction({
      type: 2, // 支出
      amount: amount,
      transactionDate: dayjs().format('YYYY-MM-DD'),
      categoryId: liab.categoryId,
      accountId: accountId,
      remark: `【分期还款】${liab.name} (第${newCurPeriod}/${liab.totalPeriods}期)`,
      liabilityId: id
    });

    // 计算顺延后的下期还款日 (往后推 periods 个月)
    const curNextDate = dayjs(liab.nextRepaymentDate || dayjs().format('YYYY-MM-DD'));
    const nextDate = curNextDate.add(periods, 'month');
    const finalNextDate = nextDate.date(Math.min(liab.repaymentDay, nextDate.daysInMonth()));

    await dbManager.run(
      `UPDATE liability SET 
        current_period = ?, 
        next_repayment_date = ?, 
        status = ?, 
        settled_at = ? 
       WHERE id = ?`,
      [
        newCurPeriod,
        finalNextDate.format('YYYY-MM-DD'),
        isSettled ? 'SETTLED' : 'REPAYING',
        isSettled ? dayjs().format('YYYY-MM-DD HH:mm:ss') : null,
        id
      ]
    );

    // 核销关联逾期待办
    await todoService.resolveTodoByBiz('LIABILITY_OVERDUE', String(id));
  },

  async settleLiability(id: number, accountId: number, settleAmount: number): Promise<void> {
    const liab = await this.getLiabilityById(id);
    if (!liab) throw new Error('Liability not found');

    // 生成一次性结清支出流水
    await transactionService.addTransaction({
      type: 2,
      amount: settleAmount,
      transactionDate: dayjs().format('YYYY-MM-DD'),
      categoryId: liab.categoryId,
      accountId: accountId,
      remark: `【提前结清】${liab.name} (全额还款)`,
      liabilityId: id
    });

    await dbManager.run(
      `UPDATE liability SET 
        current_period = total_periods, 
        status = 'SETTLED', 
        settled_at = ? 
       WHERE id = ?`,
      [dayjs().format('YYYY-MM-DD HH:mm:ss'), id]
    );

    await todoService.resolveTodoByBiz('LIABILITY_OVERDUE', String(id));
  },

  async checkAndExecuteDueRepayments(): Promise<void> {
    const todayStr = dayjs().format('YYYY-MM-DD');
    const dueLiabilities = await dbManager.query<any>(
      "SELECT * FROM liability WHERE status = 'REPAYING' AND next_repayment_date <= ?",
      [todayStr]
    );

    if (dueLiabilities.length === 0) return;

    const allAccounts = await accountService.getAccounts();

    for (const l of dueLiabilities) {
      const pAmt = Number(l.period_amount || 0);
      let targetAcc = allAccounts.find(a => a.id === l.default_account_id);

      // 1. 首选默认账户
      let canDeduct = targetAcc && targetAcc.currentBalance >= pAmt;
      let deductAccountId = canDeduct ? targetAcc!.id : null;

      // 2. 降级策略: 若默认账户不足，检查是否有其他单账户余额充足
      if (!canDeduct) {
        const fallbackAcc = allAccounts.find(a => a.id !== l.default_account_id && a.currentBalance >= pAmt);
        if (fallbackAcc) {
          canDeduct = true;
          deductAccountId = fallbackAcc.id;
        }
      }

      if (canDeduct && deductAccountId) {
        // 自动扣款
        try {
          await this.repayPeriods(l.id, 1, pAmt, deductAccountId);
          // 扣款成功后更新本地账户列表余额镜像
          const acc = allAccounts.find(a => a.id === deductAccountId);
          if (acc) acc.currentBalance -= pAmt;
        } catch (ignored) {}
      } else {
        // 余额不足，推送/保持待办告警
        const title = `【分期扣款失败】${l.name} 第${l.current_period + 1}期`;
        const content = `分期【${l.name}】本期应还 ¥${pAmt} 扣款失败，默认及降级账户余额均不足，请及时充值或更换账户补扣。`;
        await todoService.createTodoIfNotExists('LIABILITY_OVERDUE', title, content, String(l.id));
      }
    }
  }
};
