import request from '../utils/request';

export interface Account {
  id: number;
  name: string;
  type: string;
  initialBalance: number;
  currentBalance: number;
  createdAt?: string;
}

export const accountService = {
  getAccounts: () => request.get<Account[]>('/accounts'),
  async getAccountById(id: number): Promise<Account | null> { return (await this.getAccounts()).find(item => item.id === id) || null; },
  addAccount: (account: Partial<Account>) => request.post<Account>('/accounts', account),
  updateAccount: (account: Account) => request.put<Account>(`/accounts/${account.id}`, account),
  deleteAccount: (id: number) => request.delete<void>(`/accounts/${id}`),
};
