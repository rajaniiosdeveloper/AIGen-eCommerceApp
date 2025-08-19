import mongoose, { Document, Schema } from 'mongoose';

/**
 * @swagger
 * components:
 *   schemas:
 *     CartItem:
 *       type: object
 *       required:
 *         - userId
 *         - productId
 *         - quantity
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the cart item
 *         userId:
 *           type: string
 *           description: ID of the user who owns this cart item
 *         productId:
 *           type: string
 *           description: ID of the product in the cart
 *         quantity:
 *           type: integer
 *           description: Quantity of the product
 *           minimum: 1
 *         dateAdded:
 *           type: string
 *           format: date-time
 *           description: When the item was added to cart
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *       example:
 *         id: "60f7b1234567890123456789"
 *         userId: "60f7b1234567890123456780"
 *         productId: "60f7b1234567890123456781"
 *         quantity: 2
 *         dateAdded: "2023-08-04T10:30:00.000Z"
 * 
 *     Cart:
 *       type: object
 *       properties:
 *         items:
 *           type: array
 *           items:
 *             allOf:
 *               - $ref: '#/components/schemas/CartItem'
 *               - type: object
 *                 properties:
 *                   product:
 *                     $ref: '#/components/schemas/Product'
 *                   totalPrice:
 *                     type: number
 *                     description: Total price for this cart item (quantity * product price)
 *         totalAmount:
 *           type: number
 *           description: Total amount for all items in the cart
 *         totalItems:
 *           type: integer
 *           description: Total number of items in the cart
 *       example:
 *         items:
 *           - id: "60f7b1234567890123456789"
 *             userId: "60f7b1234567890123456780"
 *             productId: "60f7b1234567890123456781"
 *             quantity: 2
 *             product:
 *               id: "60f7b1234567890123456781"
 *               title: "iPhone 15 Pro"
 *               price: 999.99
 *             totalPrice: 1999.98
 *         totalAmount: 1999.98
 *         totalItems: 2
 */

export interface ICartItem extends Document {
  _id: string;
  userId: string;
  productId: string;
  quantity: number;
  dateAdded: Date;
  createdAt: Date;
  updatedAt: Date;
}

const cartItemSchema = new Schema<ICartItem>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  productId: {
    type: Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product ID is required']
  },
  quantity: {
    type: Number,
    required: [true, 'Quantity is required'],
    min: [1, 'Quantity must be at least 1'],
    validate: {
      validator: function(value: number) {
        return Number.isInteger(value) && value >= 1;
      },
      message: 'Quantity must be a positive integer'
    }
  },
  dateAdded: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
cartItemSchema.index({ userId: 1 });
cartItemSchema.index({ productId: 1 });
cartItemSchema.index({ userId: 1, productId: 1 }, { unique: true }); // Prevent duplicate items
cartItemSchema.index({ dateAdded: -1 });
cartItemSchema.index({ createdAt: -1 });

// Virtual for id (matches iOS app expectation)
cartItemSchema.virtual('id').get(function() {
  return this._id.toHexString();
});

// Static methods
cartItemSchema.statics.findByUser = function(userId: string) {
  return this.find({ userId })
    .populate('productId')
    .sort({ dateAdded: -1 });
};

cartItemSchema.statics.findUserCartItem = function(userId: string, productId: string) {
  return this.findOne({ userId, productId });
};

cartItemSchema.statics.getUserCartSummary = async function(userId: string) {
  const items = await this.find({ userId }).populate('productId');
  
  let totalAmount = 0;
  let totalItems = 0;
  
  const cartItems = items.map((item: any) => {
    const product = item.productId;
    const itemTotal = product.price * item.quantity;
    totalAmount += itemTotal;
    totalItems += item.quantity;
    
    return {
      id: item.id,
      userId: item.userId,
      productId: item.productId._id,
      quantity: item.quantity,
      dateAdded: item.dateAdded,
      product: {
        id: product.id,
        title: product.title,
        description: product.description,
        shortDescription: product.shortDescription,
        price: product.price,
        imageURL: product.imageURL,
        category: product.category,
        rating: product.rating,
        stock: product.stock,
        brand: product.brand,
        formattedPrice: product.formattedPrice,
        isInStock: product.isInStock
      },
      totalPrice: itemTotal,
      formattedTotalPrice: `₹${itemTotal.toFixed(2)}`
    };
  });
  
  return {
    items: cartItems,
    totalAmount,
    totalItems,
    formattedTotalAmount: `₹${totalAmount.toFixed(2)}`
  };
};

cartItemSchema.statics.clearUserCart = function(userId: string) {
  return this.deleteMany({ userId });
};

cartItemSchema.statics.removeExpiredItems = function(days = 30) {
  const expiryDate = new Date();
  expiryDate.setDate(expiryDate.getDate() - days);
  
  return this.deleteMany({ 
    dateAdded: { $lt: expiryDate } 
  });
};

export const CartItem = mongoose.model<ICartItem>('CartItem', cartItemSchema);