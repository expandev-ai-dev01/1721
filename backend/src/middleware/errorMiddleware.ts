/**
 * @summary
 * Global error handling middleware.
 * Catches and formats all application errors.
 *
 * @module middleware/errorMiddleware
 */
import { Request, Response, NextFunction } from 'express';

/**
 * @interface ErrorResponse
 * @description Standard error response format
 */
interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

/**
 * @function errorMiddleware
 * @description Global error handler for Express application
 *
 * @param {Error} error - Error object
 * @param {Request} req - Express request object
 * @param {Response} res - Express response object
 * @param {NextFunction} next - Express next function
 */
export async function errorMiddleware(
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const statusCode = error.statusCode || 500;
  const errorCode = error.code || 'INTERNAL_SERVER_ERROR';
  const message = error.message || 'An unexpected error occurred';

  const errorResponse: ErrorResponse = {
    success: false,
    error: {
      code: errorCode,
      message: message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    },
    timestamp: new Date().toISOString(),
  };

  console.error('Error:', {
    code: errorCode,
    message: message,
    path: req.path,
    method: req.method,
    stack: error.stack,
  });

  res.status(statusCode).json(errorResponse);
}
