import request from '../utils/request';

export interface Wishlist {
  id: number;
  name: string;
  targetAmount: number;
  deadline?: string | null;
  startDate: string;
  isRealized: number; // 0=心愿中, 1=已实现
  createdAt?: string;

  // VO 动态计算属性
  progress?: number;
  estimatedCompletionDate?: string;
  isEstimatedFallback?: boolean;
  estimatedReason?: string;
}

export const wishlistService = {
  getAllWishlists: () => request.get<Wishlist[]>('/wishlists'),
  addWishlist: (wishlist: Partial<Wishlist>) => request.post<Wishlist>('/wishlists', wishlist),
  updateWishlist: (wishlist: Wishlist) => request.put<Wishlist>(`/wishlists/${wishlist.id}`, wishlist),
  deleteWishlist: (id: number) => request.delete<void>(`/wishlists/${id}`),
  realizeWishlist: (id: number, accountId: number) => request.post<void>(`/wishlists/${id}/realize`, { accountId }),
  unrealizeWishlist: (id: number) => request.post<void>(`/wishlists/${id}/unrealize`),
};
