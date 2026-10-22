import request from '../utils/request';

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
  getStats: () => request.get<StatDTO>('/stats'),
};
