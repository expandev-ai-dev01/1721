/**
 * @summary
 * Response helper functions.
 * Standardizes API response formats.
 *
 * @module middleware/crud/responseHelpers
 */

/**
 * @interface SuccessResponse
 * @description Standard success response format
 */
interface SuccessResponse<T> {
  success: true;
  data: T;
  metadata?: {
    timestamp: string;
  };
}

/**
 * @interface ErrorResponse
 * @description Standard error response format
 */
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
  timestamp: string;
}

/**
 * @function successResponse
 * @description Creates standardized success response
 *
 * @param {T} data - Response data
 * @returns {SuccessResponse<T>}
 */
export function successResponse<T>(data: T): SuccessResponse<T> {
  return {
    success: true,
    data,
    metadata: {
      timestamp: new Date().toISOString(),
    },
  };
}

/**
 * @function errorResponse
 * @description Creates standardized error response
 *
 * @param {string} message - Error message
 * @param {string} code - Error code
 * @returns {ErrorResponse}
 */
export function errorResponse(message: string, code: string = 'ERROR'): ErrorResponse {
  return {
    success: false,
    error: {
      code,
      message,
    },
    timestamp: new Date().toISOString(),
  };
}
