import mongoose, { Document, Schema } from 'mongoose';

/**
 * @swagger
 * components:
 *   schemas:
 *     Category:
 *       type: object
 *       required:
 *         - name
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the category
 *         name:
 *           type: string
 *           description: Category name
 *           minLength: 2
 *           maxLength: 50
 *         imageURL:
 *           type: string
 *           description: Category image URL
 *         productCount:
 *           type: integer
 *           description: Number of products in this category
 *           minimum: 0
 *         isActive:
 *           type: boolean
 *           description: Whether the category is active
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *       example:
 *         id: "60f7b1234567890123456789"
 *         name: "Electronics"
 *         imageURL: "https://example.com/electronics.jpg"
 *         productCount: 25
 *         isActive: true
 */

export interface ICategory extends Document {
  _id: string;
  name: string;
  imageURL?: string;
  productCount: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const categorySchema = new Schema<ICategory>({
  name: {
    type: String,
    required: [true, 'Category name is required'],
    unique: true,
    trim: true,
    minlength: [2, 'Category name must be at least 2 characters long'],
    maxlength: [50, 'Category name cannot exceed 50 characters']
  },
  imageURL: {
    type: String,
    trim: true,
    validate: {
      validator: function(value: string) {
        if (!value) return true; // Optional field
        return /^https?:\/\/.+\.(jpg|jpeg|png|gif|webp)$/i.test(value);
      },
      message: 'Image URL must be a valid URL pointing to an image file'
    }
  },
  productCount: {
    type: Number,
    default: 0,
    min: [0, 'Product count cannot be negative'],
    validate: {
      validator: function(value: number) {
        return Number.isInteger(value) && value >= 0;
      },
      message: 'Product count must be a non-negative integer'
    }
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
categorySchema.index({ name: 1 });
categorySchema.index({ isActive: 1 });
categorySchema.index({ productCount: -1 });
categorySchema.index({ createdAt: -1 });

// Compound index
categorySchema.index({ isActive: 1, productCount: -1 });

// Virtual for id (matches iOS app expectation)
categorySchema.virtual('id').get(function() {
  return this._id.toHexString();
});

// Static methods
categorySchema.statics.findActive = function() {
  return this.find({ isActive: true }).sort({ productCount: -1, name: 1 });
};

categorySchema.statics.findByName = function(name: string) {
  return this.findOne({ 
    name: { $regex: new RegExp(`^${name}$`, 'i') },
    isActive: true 
  });
};

categorySchema.statics.updateProductCount = async function(categoryName: string) {
  const Product = mongoose.model('Product');
  const count = await Product.countDocuments({ 
    category: { $regex: new RegExp(`^${categoryName}$`, 'i') },
    isActive: true 
  });
  
  return this.findOneAndUpdate(
    { name: { $regex: new RegExp(`^${categoryName}$`, 'i') } },
    { productCount: count },
    { new: true }
  );
};

export const Category = mongoose.model<ICategory>('Category', categorySchema);