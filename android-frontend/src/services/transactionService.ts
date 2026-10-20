import request from '../utils/request';

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
  getAllTransactions: () => request.get<Transaction[]>('/transactions'),
  async getTransactionById(id: number): Promise<Transaction | null> { return (await this.getAllTransactions()).find(item => item.id === id) || null; },
  addTransaction: (tx: Transaction) => request.post<Transaction>('/transactions', tx),
  updateTransaction: (tx: Transaction) => request.put<Transaction>(`/transactions/${tx.id}`, tx),
  deleteTransaction: (id: number) => request.delete<void>(`/transactions/${id}`),
};
