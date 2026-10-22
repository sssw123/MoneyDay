import request from '../utils/request';

export interface Category {
  id: number;
  name: string;
  type: number; // 1=收入, 2=支出
  isActive: number;
  createdAt?: string;
}

export const categoryService = {
  getCategories: () => request.get<Category[]>('/categories'),
  addCategory: (category: Partial<Category>) => request.post<Category>('/categories', category),
  updateCategory: (category: Category) => request.put<Category>(`/categories/${category.id}`, category),
  async toggleCategory(id: number, isActive: number): Promise<Category> {
    const category = (await this.getCategories()).find(item => item.id === id);
    if (!category) throw new Error('分类不存在');
    return this.updateCategory({ ...category, isActive });
  },
};
