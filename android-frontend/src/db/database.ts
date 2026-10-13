import { Capacitor } from '@capacitor/core';
import { CapacitorSQLite, SQLiteConnection, SQLiteDBConnection } from '@capacitor-community/sqlite';
import { SCHEMA_SQL, SEED_SQL } from './schema';

class DatabaseManager {
  private static instance: DatabaseManager;
  private sqlite: SQLiteConnection | null = null;
  private db: SQLiteDBConnection | null = null;
  private isInitialized = false;
  private isWeb = false;

  private constructor() {}

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  public async init(): Promise<void> {
    if (this.isInitialized) return;

    this.isWeb = Capacitor.getPlatform() === 'web';
    this.sqlite = new SQLiteConnection(CapacitorSQLite);

    try {
      if (this.isWeb) {
        // 在浏览器调试环境下动态引入并挂载 jeep-sqlite 虚拟组件
        await import('jeep-sqlite');
        await customElements.whenDefined('jeep-sqlite');
        let jeepEl = document.querySelector('jeep-sqlite');
        if (!jeepEl) {
          jeepEl = document.createElement('jeep-sqlite');
          document.body.appendChild(jeepEl);
          await customElements.whenDefined('jeep-sqlite');
        }
        await this.sqlite.initWebStore();
      }

      const retCC = (await this.sqlite.checkConnectionsConsistency()).result;
      const isConn = (await this.sqlite.isConnection('moneyday_db', false)).result;

      if (retCC && isConn) {
        this.db = await this.sqlite.retrieveConnection('moneyday_db', false);
      } else {
        this.db = await this.sqlite.createConnection(
          'moneyday_db',
          false,
          'no-encryption',
          1,
          false
        );
      }

      await this.db.open();

      // 执行建表 DDL
      await this.db.execute(SCHEMA_SQL);
      // 注入初始默认数据
      await this.db.execute(SEED_SQL);

      if (this.isWeb) {
        await this.sqlite.saveToStore('moneyday_db');
      }

      this.isInitialized = true;
      console.log('[SQLite] 数据库初始化成功。平台:', Capacitor.getPlatform());
    } catch (e) {
      console.error('[SQLite] 数据库初始化发生异常:', e);
      throw e;
    }
  }

  public async query<T = any>(statement: string, values: any[] = []): Promise<T[]> {
    if (!this.db) {
      await this.init();
    }
    const res = await this.db!.query(statement, values);
    return (res.values as T[]) || [];
  }

  public async run(statement: string, values: any[] = []): Promise<{ lastId?: number; changes?: number }> {
    if (!this.db) {
      await this.init();
    }
    const res = await this.db!.run(statement, values);
    if (this.isWeb && this.sqlite) {
      try {
        await this.sqlite.saveToStore('moneyday_db');
      } catch (err) {
        console.warn('[SQLite Web] 保存到 WebStore 警告:', err);
      }
    }
    return {
      lastId: res.changes?.lastId,
      changes: res.changes?.changes
    };
  }

  public async execute(statements: string): Promise<void> {
    if (!this.db) {
      await this.init();
    }
    await this.db!.execute(statements);
    if (this.isWeb && this.sqlite) {
      try {
        await this.sqlite.saveToStore('moneyday_db');
      } catch (err) {
        console.warn('[SQLite Web] 保存到 WebStore 警告:', err);
      }
    }
  }
}

export const dbManager = DatabaseManager.getInstance();
