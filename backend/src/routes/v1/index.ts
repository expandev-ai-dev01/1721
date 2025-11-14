/**
 * @summary
 * V1 API router configuration.
 * Separates external (public) and internal (authenticated) routes.
 *
 * @module routes/v1
 */
import { Router } from 'express';
import externalRoutes from '@/routes/v1/externalRoutes';
import internalRoutes from '@/routes/v1/internalRoutes';

const router = Router();

/**
 * @rule {be-route-separation}
 * External (public) routes - /api/v1/external/...
 */
router.use('/external', externalRoutes);

/**
 * @rule {be-route-separation}
 * Internal (authenticated) routes - /api/v1/internal/...
 */
router.use('/internal', internalRoutes);

export default router;
