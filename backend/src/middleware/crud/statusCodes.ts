/**
 * @summary
 * HTTP status codes and error definitions.
 * Centralizes status code constants.
 *
 * @module middleware/crud/statusCodes
 */

/**
 * @constant StatusGeneralError
 * @description General server error object
 */
export const StatusGeneralError = {
  statusCode: 500,
  code: 'INTERNAL_SERVER_ERROR',
  message: 'An unexpected error occurred',
};
