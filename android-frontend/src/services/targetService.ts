import request from '../utils/request';

export interface Target {
  id: number;
  name: string;
  targetAmount: number;
  deadline?: string | null;
  startDate: string;
  isRealized: number; // 0=未实现, 1=已实现
  createdAt?: string;
  progress?: number;
}

export const targetService = {
  getAllTargets: () => request.get<Target[]>('/targets'),
  addTarget: (target: Partial<Target>) => request.post<Target>('/targets', target),
  updateTarget: (target: Target) => request.put<Target>(`/targets/${target.id}`, target),
  deleteTarget: (id: number) => request.delete<void>(`/targets/${id}`),
  realizeTarget: (id: number, accountId: number) => request.post<void>(`/targets/${id}/realize`, { accountId }),
  unrealizeTarget: (id: number) => request.post<void>(`/targets/${id}/unrealize`),
};
