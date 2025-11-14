/**
 * @summary
 * Database connection pool management.
 * Provides singleton connection pool for SQL Server.
 *
 * @module utils/database/connection
 */
import sql from 'mssql';
import { config } from '@/config';

let pool: sql.ConnectionPool | null = null;

/**
 * @function getPool
 * @description Gets or creates database connection pool
 *
 * @returns {Promise<sql.ConnectionPool>}
 *
 * @throws {Error} When connection fails
 */
export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    try {
      pool = await new sql.ConnectionPool(config.database).connect();
      console.log('Database connection pool established');
    } catch (error) {
      console.error('Database connection failed:', error);
      throw error;
    }
  }
  return pool;
}
