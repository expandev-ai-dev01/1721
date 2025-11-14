/**
 * @summary
 * 404 Not Found middleware.
 * Handles requests to non-existent routes.
 *
 * @module middleware/notFoundMiddleware
 */
import { Request, Response } from 'express';

/**
 * @function notFoundMiddleware
 * @description Handles 404 errors for undefined routes
 *
 * @param {Request} req - Express request object
 * @param {Response} res - Express response object
 */
export function notFoundMiddleware(req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`,
    },
    timestamp: new Date().toISOString(),
  });
}
