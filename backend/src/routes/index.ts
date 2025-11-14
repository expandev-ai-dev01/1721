/**
 * @summary
 * Main API router with version management.
 * Routes all API requests to appropriate version handlers.
 *
 * @module routes
 */
import { Router } from 'express';
import v1Routes from '@/routes/v1';

const router = Router();

/**
 * @rule {be-api-versioning}
 * Version 1 routes (current stable)
 */
router.use('/v1', v1Routes);

export default router;
