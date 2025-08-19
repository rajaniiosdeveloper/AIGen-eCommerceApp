import mongoose, { Document, Schema } from 'mongoose';

/**
 * @swagger
 * components:
 *   schemas:
 *     Product:
 *       type: object
 *       required:
 *         - title
 *         - description
 *         - price
 *         - imageURL
 *         - category
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the product
 *         title:
 *           type: string
 *           description: Product title
 *           minLength: 2
 *           maxLength: 100
 *         description:
 *           type: string
 *           description: Detailed product description
 *         shortDescription:
 *           type: string
 *           description: Brief product description
 *         price:
 *           type: number
 *           description: Product price
 *           minimum: 0
 *         imageURL:
 *           type: string
 *           description: Product image URL
 *         category:
 *           type: string
 *           description: Product category
 *         rating:
 *           type: number
 *           description: Average product rating
 *           minimum: 0
 *           maximum: 5
 *         stock:
 *           type: integer
 *           description: Available stock quantity
 *           minimum: 0
 *         brand:
 *           type: string
 *           description: Product brand
 *         isActive:
 *           type: boolean
 *           description: Whether the product is active/available
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *       example:
 *         id: "60f7b1234567890123456789"
 *         title: "iPhone 15 Pro"
 *         description: "Latest iPhone with advanced camera system"
 *         shortDescription: "Latest iPhone with advanced camera"
 *         price: 999.99
 *         imageURL: "https://example.com/iphone15.jpg"
 *         category: "Electronics"
 *         rating: 4.5
 *         stock: 50
 *         brand: "Apple"
 *         isActive: true
 */

export interface IProduct extends Document {
  _id: string;
  title: string;
  description: string;
  shortDescription: string;
  price: number;
  imageURL: string;
  category: string;
  rating: number;
  stock: number;
  brand: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  
  // Virtual properties
  formattedPrice: string;
  isInStock: boolean;
}

const productSchema = new Schema<IProduct>({
  title: {
    type: String,
    required: [true, 'Product title is required'],
    trim: true,
    minlength: [2, 'Title must be at least 2 characters long'],
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  description: {
    type: String,
    required: [true, 'Product description is required'],
    trim: true,
    minlength: [10, 'Description must be at least 10 characters long'],
    maxlength: [2000, 'Description cannot exceed 2000 characters']
  },
  shortDescription: {
    type: String,
    trim: true,
    maxlength: [200, 'Short description cannot exceed 200 characters']
  },
  price: {
    type: Number,
    required: [true, 'Product price is required'],
    min: [0, 'Price cannot be negative'],
    validate: {
      validator: function(value: number) {
        return Number.isFinite(value) && value >= 0;
      },
      message: 'Price must be a valid positive number'
    }
  },
  imageURL: {
    type: String,
    required: [true, 'Product image URL is required'],
    trim: true,
    validate: {
      validator: function(value: string) {
        return /^https?:\/\/.+\.(jpg|jpeg|png|gif|webp)$/i.test(value);
      },
      message: 'Image URL must be a valid URL pointing to an image file'
    }
  },
  category: {
    type: String,
    required: [true, 'Product category is required'],
    trim: true,
    default: 'General'
  },
  rating: {
    type: Number,
    default: 0,
    min: [0, 'Rating cannot be less than 0'],
    max: [5, 'Rating cannot be more than 5'],
    validate: {
      validator: function(value: number) {
        return Number.isFinite(value) && value >= 0 && value <= 5;
      },
      message: 'Rating must be between 0 and 5'
    }
  },
  stock: {
    type: Number,
    required: [true, 'Stock quantity is required'],
    min: [0, 'Stock cannot be negative'],
    default: 0,
    validate: {
      validator: function(value: number) {
        return Number.isInteger(value) && value >= 0;
      },
      message: 'Stock must be a non-negative integer'
    }
  },
  brand: {
    type: String,
    trim: true,
    default: '',
    maxlength: [50, 'Brand name cannot exceed 50 characters']
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
productSchema.index({ title: 'text', description: 'text' }); // Text search
productSchema.index({ category: 1 });
productSchema.index({ brand: 1 });
productSchema.index({ price: 1 });
productSchema.index({ rating: -1 });
productSchema.index({ stock: 1 });
productSchema.index({ isActive: 1 });
productSchema.index({ createdAt: -1 });

// Compound indexes
productSchema.index({ category: 1, isActive: 1, stock: 1 });
productSchema.index({ isActive: 1, stock: 1, rating: -1 });

// Virtual for id (matches iOS app expectation)
productSchema.virtual('id').get(function() {
  return this._id.toHexString();
});

// Virtual for formatted price (matches iOS app)
productSchema.virtual('formattedPrice').get(function() {
  return `₹${this.price.toFixed(2)}`;
});

// Virtual for stock status (matches iOS app)
productSchema.virtual('isInStock').get(function() {
  return this.stock > 0;
});

// Pre-save middleware to generate short description if not provided
productSchema.pre('save', function(next) {
  if (!this.shortDescription && this.description) {
    this.shortDescription = this.description.length > 80 
      ? this.description.substring(0, 80) + '...'
      : this.description;
  }
  next();
});

// Static methods
productSchema.statics.findByCategory = function(category: string) {
  return this.find({ 
    category: { $regex: new RegExp(category, 'i') }, 
    isActive: true, 
    stock: { $gt: 0 } 
  }).sort({ rating: -1, createdAt: -1 });
};

productSchema.statics.searchProducts = function(query: string) {
  return this.find({ 
    $text: { $search: query },
    isActive: true,
    stock: { $gt: 0 }
  }).sort({ score: { $meta: 'textScore' }, rating: -1 });
};

productSchema.statics.findInStock = function() {
  return this.find({ 
    isActive: true, 
    stock: { $gt: 0 } 
  }).sort({ rating: -1, createdAt: -1 });
};

productSchema.statics.findFeatured = function(limit = 10) {
  return this.find({ 
    isActive: true, 
    stock: { $gt: 0 },
    rating: { $gte: 4 }
  }).sort({ rating: -1, stock: -1 }).limit(limit);
};

export const Product = mongoose.model<IProduct>('Product', productSchema);