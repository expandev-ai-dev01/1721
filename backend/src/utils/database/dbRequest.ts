/**
 * @summary
 * Database request utility.
 * Executes stored procedures with proper error handling.
 *
 * @module utils/database/dbRequest
 */
import sql from 'mssql';
import { getPool } from '@/utils/database/connection';
import { IRecordSet } from '@/utils/database/types';

/**
 * @enum ExpectedReturn
 * @description Expected return type from stored procedure
 */
export enum ExpectedReturn {
  Single = 'Single',
  Multi = 'Multi',
  None = 'None',
}

/**
 * @function dbRequest
 * @description Executes stored procedure with parameters
 *
 * @param {string} procedure - Stored procedure name
 * @param {object} parameters - Procedure parameters
 * @param {ExpectedReturn} expectedReturn - Expected return type
 * @param {sql.Transaction} transaction - Optional transaction
 * @param {string[]} resultSetNames - Optional result set names
 *
 * @returns {Promise<any>}
 *
 * @throws {Error} When procedure execution fails
 */
export async function dbRequest(
  procedure: string,
  parameters: { [key: string]: any },
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  try {
    const pool = await getPool();
    const request = transaction ? new sql.Request(transaction) : pool.request();

    /**
     * @rule {be-parameter-binding}
     * Bind parameters to request
     */
    for (const [key, value] of Object.entries(parameters)) {
      request.input(key, value);
    }

    /**
     * @rule {be-procedure-execution}
     * Execute stored procedure
     */
    const result = await request.execute(procedure);

    /**
     * @rule {be-result-processing}
     * Process results based on expected return type
     */
    if (expectedReturn === ExpectedReturn.None) {
      return null;
    }

    if (expectedReturn === ExpectedReturn.Single) {
      return result.recordset[0];
    }

    if (expectedReturn === ExpectedReturn.Multi) {
      if (resultSetNames && resultSetNames.length > 0) {
        const namedResults: { [key: string]: IRecordSet<any> } = {};
        resultSetNames.forEach((name, index) => {
          namedResults[name] = result.recordsets[index];
        });
        return namedResults;
      }
      return result.recordsets;
    }

    return result.recordset;
  } catch (error) {
    console.error('Database request failed:', {
      procedure,
      parameters,
      error,
    });
    throw error;
  }
}
