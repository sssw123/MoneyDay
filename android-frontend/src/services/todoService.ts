import { dbManager } from '../db';
import { liabilityService } from './liabilityService';

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
  async getTodos(status?: string): Promise<TodoItem[]> {
    let sql = 'SELECT * FROM todo_item';
    const params: any[] = [];
    if (status) {
      sql += ' WHERE status = ?';
      params.push(status);
    }
    sql += ' ORDER BY id DESC';

    const rows = await dbManager.query<any>(sql, params);
    return rows.map(r => ({
      id: r.id,
      type: r.type,
      title: r.title,
      content: r.content,
      bizId: r.biz_id,
      status: r.status,
      createdAt: r.created_at,
      updatedAt: r.updated_at
    }));
  },

  async countPending(): Promise<number> {
    const rows = await dbManager.query<any>(
      "SELECT COUNT(*) as cnt FROM todo_item WHERE status = 'PENDING'"
    );
    return Number(rows[0]?.cnt || 0);
  },

  async dismissTodo(id: number): Promise<void> {
    await dbManager.run(
      "UPDATE todo_item SET status = 'DISMISSED', updated_at = datetime('now', 'localtime') WHERE id = ?",
      [id]
    );
  },

  async resolveTodo(id: number): Promise<void> {
    await dbManager.run(
      "UPDATE todo_item SET status = 'RESOLVED', updated_at = datetime('now', 'localtime') WHERE id = ?",
      [id]
    );
  },

  async createTodoIfNotExists(type: string, title: string, content: string, bizId: string): Promise<void> {
    const existing = await dbManager.query<any>(
      "SELECT id FROM todo_item WHERE type = ? AND biz_id = ? AND status = 'PENDING' LIMIT 1",
      [type, bizId]
    );
    if (existing.length === 0) {
      await dbManager.run(
        'INSERT INTO todo_item (type, title, content, biz_id, status) VALUES (?, ?, ?, ?, ?)',
        [type, title, content, bizId, 'PENDING']
      );
    }
  },

  async resolveTodoByBiz(type: string, bizId: string): Promise<void> {
    await dbManager.run(
      "UPDATE todo_item SET status = 'RESOLVED', updated_at = datetime('now', 'localtime') WHERE type = ? AND biz_id = ? AND status = 'PENDING'",
      [type, bizId]
    );
  },

  async retryLiabilityRepayment(todoId: number, accountId?: number): Promise<void> {
    const rows = await dbManager.query<any>('SELECT * FROM todo_item WHERE id = ?', [todoId]);
    if (rows.length === 0) throw new Error('Todo item not found');
    const todo = rows[0];
    const liabilityId = Number(todo.biz_id);

    const liab = await liabilityService.getLiabilityById(liabilityId);
    if (!liab) throw new Error('Associated liability not found');

    const deductAccId = accountId || liab.defaultAccountId || 1;
    await liabilityService.repayPeriods(liabilityId, 1, liab.periodAmount, deductAccId);

    // 核销待办
    await this.resolveTodo(todoId);
  }
};
