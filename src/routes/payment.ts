import express from 'express';
import { authenticate } from '@/middleware/auth';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Payment
 *   description: Payment processing endpoints
 */

router.use(authenticate);
router.post('/initiate', (req, res) => res.json({ status: 'success', message: 'Initiate payment - implement controller' }));
router.post('/verify', (req, res) => res.json({ status: 'success', message: 'Verify payment - implement controller' }));

export default router;