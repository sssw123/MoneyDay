import { dbManager } from '../db';

export interface Category {
  id: number;
  name: string;
  type: number; // 1=收入, 2=支出
  isActive: number;
  createdAt?: string;
}

export const categoryService = {
  async getCategories(): Promise<Category[]> {
    const rows = await dbManager.query<any>('SELECT * FROM category ORDER BY id ASC');
    return rows.map(r => ({
      id: r.id,
      name: r.name,
      type: Number(r.type),
      isActive: Number(r.is_active),
      createdAt: r.created_at
    }));
  },

  async addCategory(category: Partial<Category>): Promise<number> {
    const res = await dbManager.run(
      'INSERT INTO category (name, type, is_active) VALUES (?, ?, ?)',
      [category.name, category.type || 2, category.isActive ?? 1]
    );
    return res.lastId || 0;
  },

  async updateCategory(category: Category): Promise<void> {
    await dbManager.run(
      'UPDATE category SET name = ?, type = ?, is_active = ? WHERE id = ?',
      [category.name, category.type, category.isActive, category.id]
    );
  },

  async toggleCategory(id: number, isActive: number): Promise<void> {
    await dbManager.run(
      'UPDATE category SET is_active = ? WHERE id = ?',
      [isActive, id]
    );
  }
};
