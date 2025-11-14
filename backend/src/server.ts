/**
 * @summary
 * Main server entry point for LoveCakes backend API.
 * Configures Express application with middleware, routes, and error handling.
 *
 * @module server
 */
import express, { Application, Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import { config } from '@/config';
import { errorMiddleware } from '@/middleware/errorMiddleware';
import { notFoundMiddleware } from '@/middleware/notFoundMiddleware';
import apiRoutes from '@/routes';

const app: Application = express();

/**
 * @rule {be-security-middleware}
 * Security middleware configuration
 */
app.use(helmet());
app.use(cors(config.api.cors));

/**
 * @rule {be-request-processing}
 * Request processing middleware
 */
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

/**
 * @rule {be-health-check}
 * Health check endpoint (no versioning)
 */
app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'lovecakes-backend',
  });
});

/**
 * @rule {be-api-versioning}
 * API Routes with versioning
 * Creates routes like:
 * - /api/v1/external/...
 * - /api/v1/internal/...
 */
app.use('/api', apiRoutes);

/**
 * @rule {be-error-handling}
 * Error handling middleware
 */
app.use(notFoundMiddleware);
app.use(errorMiddleware);

/**
 * @rule {be-graceful-shutdown}
 * Graceful shutdown handler
 */
process.on('SIGTERM', () => {
  console.log('SIGTERM received, closing server gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

/**
 * @rule {be-server-startup}
 * Server startup
 */
const server = app.listen(config.api.port, () => {
  console.log(
    `LoveCakes Backend running on port ${config.api.port} in ${process.env.NODE_ENV} mode`
  );
});

export default server;
