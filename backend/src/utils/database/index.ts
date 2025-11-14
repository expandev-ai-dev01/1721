/**
 * @summary
 * Database utilities exports.
 * Centralizes database connection and query utilities.
 *
 * @module utils/database
 */
export { getPool } from '@/utils/database/connection';
export { dbRequest, ExpectedReturn } from '@/utils/database/dbRequest';
export type { IRecordSet, ICreateObjectResult } from '@/utils/database/types';
