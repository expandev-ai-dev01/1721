/**
 * @summary
 * Middleware exports.
 * Centralizes all middleware functions for easy import.
 *
 * @module middleware
 */
export { errorMiddleware } from '@/middleware/errorMiddleware';
export { notFoundMiddleware } from '@/middleware/notFoundMiddleware';
export { authMiddleware } from '@/middleware/authMiddleware';
export { validationMiddleware } from '@/middleware/validationMiddleware';
