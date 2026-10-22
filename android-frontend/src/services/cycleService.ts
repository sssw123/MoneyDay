import request from '../utils/request';

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
  getCycleTemplates: () => request.get<CycleTemplate[]>('/cycle-templates'),
  async getDefaultTemplate(): Promise<CycleTemplate | null> {
    const items = await this.getCycleTemplates();
    return items.find(item => item.isDefault === 1) || items[0] || null;
  },
  saveCycleTemplate: (template: CycleTemplate) => request.put<CycleTemplate>(`/cycle-templates/${template.id}`, { ...template, startDay: Number(template.startDay) }),
  async getRecentCycles(limit = 6): Promise<CycleRecord[]> { return (await request.get<CycleRecord[]>('/cycles')).slice(0, limit); },
  bookItem: (cycleId: number, itemId: string, accountId: number, amount: number, date: string) => request.post<Pick<CycleRecord, 'id' | 'fixedItems'>>(`/cycles/${cycleId}/book-item/${encodeURIComponent(itemId)}`, { accountId, amount, date }),
  unbookItem: (cycleId: number, itemId: string) => request.post<Pick<CycleRecord, 'id' | 'fixedItems'>>(`/cycles/${cycleId}/unbook-item/${encodeURIComponent(itemId)}`),
  getTotalCumulativeBalance: () => request.get<number>('/targets/cumulative-balance'),
};
