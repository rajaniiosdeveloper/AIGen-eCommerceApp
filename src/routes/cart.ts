import express from 'express';
import { body, param } from 'express-validator';
import {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart
} from '@/controllers/cartController';
import { authenticate } from '@/middleware/auth';
import { validateRequest } from '@/middleware/validation';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Cart
 *   description: Shopping cart management endpoints
 */

// Validation rules
const addToCartValidation = [
  body('productId')
    .notEmpty()
    .isMongoId()
    .withMessage('Valid product ID is required'),
  body('quantity')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Quantity must be between 1 and 100')
];

const updateCartValidation = [
  param('itemId')
    .isMongoId()
    .withMessage('Valid item ID is required'),
  body('quantity')
    .isInt({ min: 1, max: 100 })
    .withMessage('Quantity must be between 1 and 100')
];

const removeFromCartValidation = [
  param('itemId')
    .isMongoId()
    .withMessage('Valid item ID is required')
];

// All cart routes require authentication
router.use(authenticate);

// Routes
router.get('/', getCart);
router.post('/', addToCartValidation, validateRequest, addToCart);
router.put('/:itemId', updateCartValidation, validateRequest, updateCartItem);
router.delete('/:itemId', removeFromCartValidation, validateRequest, removeFromCart);
router.delete('/', clearCart);

export default router;