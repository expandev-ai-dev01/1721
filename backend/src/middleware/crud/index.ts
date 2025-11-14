/**
 * @summary
 * CRUD middleware exports.
 * Provides base CRUD controller functionality.
 *
 * @module middleware/crud
 */
export { CrudController } from '@/middleware/crud/CrudController';
export { successResponse, errorResponse } from '@/middleware/crud/responseHelpers';
export { StatusGeneralError } from '@/middleware/crud/statusCodes';
