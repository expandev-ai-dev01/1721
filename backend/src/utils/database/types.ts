/**
 * @summary
 * Database type definitions.
 * Defines common database result types.
 *
 * @module utils/database/types
 */

/**
 * @interface IRecordSet
 * @description Generic record set type
 */
export interface IRecordSet<T> extends Array<T> {}

/**
 * @interface ICreateObjectResult
 * @description Standard create operation result
 */
export interface ICreateObjectResult {
  id: number;
  dateCreated: Date;
}
