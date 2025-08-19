import express from 'express';
import { getAllCategories, getCategoryById } from '@/controllers/categoryController';
import { optionalAuth } from '@/middleware/auth';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Categories
 *   description: Product category management endpoints
 */

router.get('/', optionalAuth, getAllCategories);
router.get('/:id', optionalAuth, getCategoryById);

export default router;