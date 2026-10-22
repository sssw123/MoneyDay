import request from '../utils/request';

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
  getAllLiabilities: () => request.get<Liability[]>('/liabilities'),
  async getLiabilityById(id: number): Promise<Liability | null> { return (await this.getAllLiabilities()).find(item => item.id === id) || null; },
  addLiability: (liability: Partial<Liability>) => request.post<Liability>('/liabilities', liability),
  updateLiability: (liability: Liability) => request.put<Liability>(`/liabilities/${liability.id}`, liability),
  deleteLiability: (id: number) => request.delete<void>(`/liabilities/${id}`),
  repayPeriods: (id: number, periods: number, amount: number, accountId: number) => request.post<void>(`/liabilities/${id}/repay`, { periods, amount, accountId }),
  settleLiability: (id: number, accountId: number, settleAmount: number) => request.post<void>(`/liabilities/${id}/settle`, { accountId, settleAmount }),
};
