import mongoose, { Document, Schema } from 'mongoose';

/**
 * @swagger
 * components:
 *   schemas:
 *     WishlistItem:
 *       type: object
 *       required:
 *         - userId
 *         - productId
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the wishlist item
 *         userId:
 *           type: string
 *           description: ID of the user who owns this wishlist item
 *         productId:
 *           type: string
 *           description: ID of the product in the wishlist
 *         dateAdded:
 *           type: string
 *           format: date-time
 *           description: When the item was added to wishlist
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
 *         dateAdded: "2023-08-04T10:30:00.000Z"
 * 
 *     Wishlist:
 *       type: object
 *       properties:
 *         items:
 *           type: array
 *           items:
 *             allOf:
 *               - $ref: '#/components/schemas/WishlistItem'
 *               - type: object
 *                 properties:
 *                   product:
 *                     $ref: '#/components/schemas/Product'
 *         totalItems:
 *           type: integer
 *           description: Total number of items in the wishlist
 *       example:
 *         items:
 *           - id: "60f7b1234567890123456789"
 *             userId: "60f7b1234567890123456780"
 *             productId: "60f7b1234567890123456781"
 *             product:
 *               id: "60f7b1234567890123456781"
 *               title: "iPhone 15 Pro"
 *               price: 999.99
 *         totalItems: 1
 */

export interface IWishlistItem extends Document {
  _id: string;
  userId: string;
  productId: string;
  dateAdded: Date;
  createdAt: Date;
  updatedAt: Date;
}

const wishlistItemSchema = new Schema<IWishlistItem>({
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
wishlistItemSchema.index({ userId: 1 });
wishlistItemSchema.index({ productId: 1 });
wishlistItemSchema.index({ userId: 1, productId: 1 }, { unique: true }); // Prevent duplicate items
wishlistItemSchema.index({ dateAdded: -1 });
wishlistItemSchema.index({ createdAt: -1 });

// Virtual for id (matches iOS app expectation)
wishlistItemSchema.virtual('id').get(function() {
  return this._id.toHexString();
});

// Static methods
wishlistItemSchema.statics.findByUser = function(userId: string) {
  return this.find({ userId })
    .populate('productId')
    .sort({ dateAdded: -1 });
};

wishlistItemSchema.statics.findUserWishlistItem = function(userId: string, productId: string) {
  return this.findOne({ userId, productId });
};

wishlistItemSchema.statics.getUserWishlist = async function(userId: string) {
  const items = await this.find({ userId }).populate('productId');
  
  const wishlistItems = items.map((item: any) => {
    const product = item.productId;
    
    return {
      id: item.id,
      userId: item.userId,
      productId: item.productId._id,
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
      }
    };
  });
  
  return {
    items: wishlistItems,
    totalItems: wishlistItems.length
  };
};

wishlistItemSchema.statics.isInWishlist = async function(userId: string, productId: string) {
  const item = await this.findOne({ userId, productId });
  return !!item;
};

wishlistItemSchema.statics.getWishlistCount = function(userId: string) {
  return this.countDocuments({ userId });
};

wishlistItemSchema.statics.clearUserWishlist = function(userId: string) {
  return this.deleteMany({ userId });
};

wishlistItemSchema.statics.removeExpiredItems = function(days = 90) {
  const expiryDate = new Date();
  expiryDate.setDate(expiryDate.getDate() - days);
  
  return this.deleteMany({ 
    dateAdded: { $lt: expiryDate } 
  });
};

wishlistItemSchema.statics.moveToCart = async function(userId: string, productId: string) {
  const CartItem = mongoose.model('CartItem');
  
  // Check if item exists in wishlist
  const wishlistItem = await this.findOne({ userId, productId });
  if (!wishlistItem) {
    throw new Error('Item not found in wishlist');
  }
  
  // Add to cart (or update quantity if already exists)
  const existingCartItem = await CartItem.findOne({ userId, productId });
  if (existingCartItem) {
    existingCartItem.quantity += 1;
    await existingCartItem.save();
  } else {
    await CartItem.create({ userId, productId, quantity: 1 });
  }
  
  // Remove from wishlist
  await this.findByIdAndDelete(wishlistItem._id);
  
  return { success: true, message: 'Item moved to cart successfully' };
};

export const WishlistItem = mongoose.model<IWishlistItem>('WishlistItem', wishlistItemSchema);