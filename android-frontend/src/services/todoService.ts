import request from '../utils/request';

export interface TodoItem {
  id: number;
  type: 'LIABILITY_OVERDUE' | 'CYCLE_FIXED_ITEMS' | 'WISHLIST_REACHED';
  title: string;
  content: string;
  bizId: string;
  status: 'PENDING' | 'RESOLVED' | 'DISMISSED';
  createdAt?: string;
  updatedAt?: string;
}

export const todoService = {
  getTodos: (status = 'PENDING') => request.get<TodoItem[]>('/todos', { params: { status } }),
  async countPending(): Promise<number> { return (await request.get<{ count: number }>('/todos/pending-count')).count; },
  dismissTodo: (id: number) => request.post<void>(`/todos/${id}/dismiss`),
  resolveTodo: (id: number) => request.post<void>(`/todos/${id}/resolve`),
  retryLiabilityRepayment: (todoId: number, accountId?: number) => request.post<void>(`/todos/${todoId}/retry-repay`, { accountId }),
};
