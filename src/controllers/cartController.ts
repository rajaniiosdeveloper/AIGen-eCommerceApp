import { Request, Response, NextFunction } from 'express';
import { CartItem } from '@/models/Cart';
import { Product } from '@/models/Product';
import { AppError } from '@/utils/AppError';
import { catchAsync } from '@/utils/catchAsync';
import { io } from '@/server';
import { SocketEmitter } from '@/services/socketService';

interface AuthRequest extends Request {
  user?: any;
}

const socketEmitter = new SocketEmitter(io);

/**
 * @swagger
 * /api/cart:
 *   get:
 *     summary: Get user's cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Cart retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: "success"
 *                 message:
 *                   type: string
 *                   example: "Cart retrieved successfully"
 *                 data:
 *                   $ref: '#/components/schemas/Cart'
 */
export const getCart = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const userId = req.user.id;
  const cart = await CartItem.getUserCartSummary(userId);

  res.status(200).json({
    status: 'success',
    message: 'Cart retrieved successfully',
    data: cart
  });
});

/**
 * @swagger
 * /api/cart:
 *   post:
 *     summary: Add item to cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - productId
 *               - quantity
 *             properties:
 *               productId:
 *                 type: string
 *               quantity:
 *                 type: integer
 *                 minimum: 1
 *                 default: 1
 *     responses:
 *       201:
 *         description: Item added to cart successfully
 *       400:
 *         description: Invalid request data
 *       404:
 *         description: Product not found
 */
export const addToCart = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const userId = req.user.id;
  const { productId, quantity = 1 } = req.body;

  if (!productId) {
    return next(new AppError('Product ID is required', 400));
  }

  // Check if product exists and is available
  const product = await Product.findOne({ _id: productId, isActive: true });
  if (!product) {
    return next(new AppError('Product not found or unavailable', 404));
  }

  if (product.stock < quantity) {
    return next(new AppError(`Only ${product.stock} items available in stock`, 400));
  }

  // Check if item already exists in cart
  const existingItem = await CartItem.findUserCartItem(userId, productId);
  
  let cartItem;
  if (existingItem) {
    // Update quantity
    const newQuantity = existingItem.quantity + quantity;
    if (product.stock < newQuantity) {
      return next(new AppError(`Cannot add ${quantity} more items. Only ${product.stock - existingItem.quantity} more available`, 400));
    }
    
    existingItem.quantity = newQuantity;
    cartItem = await existingItem.save();
  } else {
    // Create new cart item
    cartItem = await CartItem.create({
      userId,
      productId,
      quantity
    });
  }

  // Get updated cart summary
  const cart = await CartItem.getUserCartSummary(userId);

  // Emit real-time update
  socketEmitter.emitCartItemAdded(userId, {
    id: cartItem.id,
    productId,
    quantity: cartItem.quantity,
    product: {
      id: product.id,
      title: product.title,
      price: product.price,
      imageURL: product.imageURL
    }
  });

  res.status(201).json({
    status: 'success',
    message: 'Item added to cart successfully',
    data: {
      cartItem: {
        id: cartItem.id,
        userId: cartItem.userId,
        productId: cartItem.productId,
        quantity: cartItem.quantity,
        dateAdded: cartItem.dateAdded
      },
      cart
    }
  });
});

/**
 * @swagger
 * /api/cart/{itemId}:
 *   put:
 *     summary: Update cart item quantity
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: itemId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - quantity
 *             properties:
 *               quantity:
 *                 type: integer
 *                 minimum: 1
 *     responses:
 *       200:
 *         description: Cart item updated successfully
 *       404:
 *         description: Cart item not found
 */
export const updateCartItem = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const userId = req.user.id;
  const { itemId } = req.params;
  const { quantity } = req.body;

  if (!quantity || quantity < 1) {
    return next(new AppError('Quantity must be at least 1', 400));
  }

  const cartItem = await CartItem.findOne({ _id: itemId, userId });
  if (!cartItem) {
    return next(new AppError('Cart item not found', 404));
  }

  // Check product availability
  const product = await Product.findById(cartItem.productId);
  if (!product || !product.isActive) {
    return next(new AppError('Product is no longer available', 404));
  }

  if (product.stock < quantity) {
    return next(new AppError(`Only ${product.stock} items available in stock`, 400));
  }

  cartItem.quantity = quantity;
  await cartItem.save();

  const cart = await CartItem.getUserCartSummary(userId);

  // Emit real-time update
  socketEmitter.emitCartUpdate(userId, cart);

  res.status(200).json({
    status: 'success',
    message: 'Cart item updated successfully',
    data: { cart }
  });
});

/**
 * @swagger
 * /api/cart/{itemId}:
 *   delete:
 *     summary: Remove item from cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: itemId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Item removed from cart successfully
 *       404:
 *         description: Cart item not found
 */
export const removeFromCart = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const userId = req.user.id;
  const { itemId } = req.params;

  const cartItem = await CartItem.findOneAndDelete({ _id: itemId, userId });
  if (!cartItem) {
    return next(new AppError('Cart item not found', 404));
  }

  const cart = await CartItem.getUserCartSummary(userId);

  // Emit real-time update
  socketEmitter.emitCartItemRemoved(userId, itemId);

  res.status(200).json({
    status: 'success',
    message: 'Item removed from cart successfully',
    data: { cart }
  });
});

/**
 * @swagger
 * /api/cart/clear:
 *   delete:
 *     summary: Clear all items from cart
 *     tags: [Cart]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Cart cleared successfully
 */
export const clearCart = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const userId = req.user.id;

  await CartItem.clearUserCart(userId);

  // Emit real-time update
  socketEmitter.emitCartCleared(userId);

  res.status(200).json({
    status: 'success',
    message: 'Cart cleared successfully',
    data: {
      cart: {
        items: [],
        totalAmount: 0,
        totalItems: 0,
        formattedTotalAmount: '₹0.00'
      }
    }
  });
});