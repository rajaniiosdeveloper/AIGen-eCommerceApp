import mongoose, { Document, Schema } from 'mongoose';

/**
 * @swagger
 * components:
 *   schemas:
 *     OrderItem:
 *       type: object
 *       required:
 *         - productId
 *         - productTitle
 *         - productImageURL
 *         - quantity
 *         - unitPrice
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the order item
 *         productId:
 *           type: string
 *           description: ID of the ordered product
 *         productTitle:
 *           type: string
 *           description: Title of the ordered product
 *         productImageURL:
 *           type: string
 *           description: Image URL of the ordered product
 *         quantity:
 *           type: integer
 *           description: Quantity ordered
 *           minimum: 1
 *         unitPrice:
 *           type: number
 *           description: Price per unit at the time of order
 *           minimum: 0
 *         totalPrice:
 *           type: number
 *           description: Total price for this item (quantity * unitPrice)
 *           minimum: 0
 *       example:
 *         id: "60f7b1234567890123456789"
 *         productId: "60f7b1234567890123456781"
 *         productTitle: "iPhone 15 Pro"
 *         productImageURL: "https://example.com/iphone15.jpg"
 *         quantity: 1
 *         unitPrice: 999.99
 *         totalPrice: 999.99
 * 
 *     Order:
 *       type: object
 *       required:
 *         - userId
 *         - items
 *         - totalAmount
 *         - shippingAddress
 *       properties:
 *         id:
 *           type: string
 *           description: Unique identifier for the order
 *         userId:
 *           type: string
 *           description: ID of the user who placed the order
 *         items:
 *           type: array
 *           items:
 *             $ref: '#/components/schemas/OrderItem'
 *           description: List of items in the order
 *         totalAmount:
 *           type: number
 *           description: Total amount for the order
 *           minimum: 0
 *         status:
 *           type: string
 *           enum: [pending, confirmed, processing, shipped, delivered, cancelled]
 *           description: Current status of the order
 *         orderDate:
 *           type: string
 *           format: date-time
 *           description: When the order was placed
 *         deliveryDate:
 *           type: string
 *           format: date-time
 *           description: Expected or actual delivery date
 *         shippingAddress:
 *           type: string
 *           description: Shipping address for the order
 *         paymentStatus:
 *           type: string
 *           enum: [pending, paid, failed, refunded]
 *           description: Payment status
 *         paymentId:
 *           type: string
 *           description: Payment transaction ID
 *         trackingNumber:
 *           type: string
 *           description: Shipping tracking number
 *         createdAt:
 *           type: string
 *           format: date-time
 *         updatedAt:
 *           type: string
 *           format: date-time
 *       example:
 *         id: "60f7b1234567890123456789"
 *         userId: "60f7b1234567890123456780"
 *         items:
 *           - id: "60f7b1234567890123456791"
 *             productId: "60f7b1234567890123456781"
 *             productTitle: "iPhone 15 Pro"
 *             quantity: 1
 *             unitPrice: 999.99
 *             totalPrice: 999.99
 *         totalAmount: 999.99
 *         status: "pending"
 *         orderDate: "2023-08-04T10:30:00.000Z"
 *         shippingAddress: "123 Main St, City, State 12345"
 *         paymentStatus: "pending"
 */

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  FAILED = 'failed',
  REFUNDED = 'refunded'
}

export interface IOrderItem {
  _id?: string;
  productId: string;
  productTitle: string;
  productImageURL: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface IOrder extends Document {
  _id: string;
  userId: string;
  items: IOrderItem[];
  totalAmount: number;
  status: OrderStatus;
  orderDate: Date;
  deliveryDate?: Date;
  shippingAddress: string;
  paymentStatus: PaymentStatus;
  paymentId?: string;
  trackingNumber?: string;
  createdAt: Date;
  updatedAt: Date;
  
  // Virtual properties
  formattedTotal: string;
  formattedOrderDate: string;
  itemCount: number;
}

const orderItemSchema = new Schema<IOrderItem>({
  productId: {
    type: Schema.Types.ObjectId,
    ref: 'Product',
    required: [true, 'Product ID is required']
  },
  productTitle: {
    type: String,
    required: [true, 'Product title is required'],
    trim: true
  },
  productImageURL: {
    type: String,
    required: [true, 'Product image URL is required'],
    trim: true
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
  unitPrice: {
    type: Number,
    required: [true, 'Unit price is required'],
    min: [0, 'Unit price cannot be negative']
  },
  totalPrice: {
    type: Number,
    required: [true, 'Total price is required'],
    min: [0, 'Total price cannot be negative']
  }
}, {
  _id: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

const orderSchema = new Schema<IOrder>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required']
  },
  items: {
    type: [orderItemSchema],
    required: [true, 'Order items are required'],
    validate: {
      validator: function(items: IOrderItem[]) {
        return items && items.length > 0;
      },
      message: 'Order must contain at least one item'
    }
  },
  totalAmount: {
    type: Number,
    required: [true, 'Total amount is required'],
    min: [0, 'Total amount cannot be negative']
  },
  status: {
    type: String,
    enum: Object.values(OrderStatus),
    default: OrderStatus.PENDING
  },
  orderDate: {
    type: Date,
    default: Date.now
  },
  deliveryDate: {
    type: Date
  },
  shippingAddress: {
    type: String,
    required: [true, 'Shipping address is required'],
    trim: true,
    minlength: [10, 'Shipping address must be at least 10 characters long'],
    maxlength: [500, 'Shipping address cannot exceed 500 characters']
  },
  paymentStatus: {
    type: String,
    enum: Object.values(PaymentStatus),
    default: PaymentStatus.PENDING
  },
  paymentId: {
    type: String,
    trim: true
  },
  trackingNumber: {
    type: String,
    trim: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for better query performance
orderSchema.index({ userId: 1 });
orderSchema.index({ status: 1 });
orderSchema.index({ paymentStatus: 1 });
orderSchema.index({ orderDate: -1 });
orderSchema.index({ trackingNumber: 1 });
orderSchema.index({ paymentId: 1 });
orderSchema.index({ createdAt: -1 });

// Compound indexes
orderSchema.index({ userId: 1, status: 1, orderDate: -1 });
orderSchema.index({ userId: 1, paymentStatus: 1 });

// Virtual for id (matches iOS app expectation)
orderSchema.virtual('id').get(function() {
  return this._id.toHexString();
});

// Virtual for formatted total (matches iOS app)
orderSchema.virtual('formattedTotal').get(function() {
  return `₹${this.totalAmount.toFixed(2)}`;
});

// Virtual for formatted order date (matches iOS app)
orderSchema.virtual('formattedOrderDate').get(function() {
  return this.orderDate.toLocaleDateString('en-IN', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  });
});

// Virtual for item count (matches iOS app)
orderSchema.virtual('itemCount').get(function() {
  return this.items.reduce((total, item) => total + item.quantity, 0);
});

// Pre-save middleware to calculate delivery date
orderSchema.pre('save', function(next) {
  if (this.isNew && !this.deliveryDate) {
    // Set delivery date to 7 days from order date
    const deliveryDate = new Date(this.orderDate);
    deliveryDate.setDate(deliveryDate.getDate() + 7);
    this.deliveryDate = deliveryDate;
  }
  next();
});

// Pre-save middleware to validate total amount
orderSchema.pre('save', function(next) {
  const calculatedTotal = this.items.reduce((total, item) => total + item.totalPrice, 0);
  if (Math.abs(this.totalAmount - calculatedTotal) > 0.01) {
    return next(new Error('Total amount does not match sum of item prices'));
  }
  next();
});

// Static methods
orderSchema.statics.findByUser = function(userId: string, status?: OrderStatus) {
  const query: any = { userId };
  if (status) query.status = status;
  
  return this.find(query)
    .populate('userId', 'name email')
    .sort({ orderDate: -1 });
};

orderSchema.statics.findByStatus = function(status: OrderStatus) {
  return this.find({ status })
    .populate('userId', 'name email')
    .sort({ orderDate: -1 });
};

orderSchema.statics.findByPaymentStatus = function(paymentStatus: PaymentStatus) {
  return this.find({ paymentStatus })
    .populate('userId', 'name email')
    .sort({ orderDate: -1 });
};

orderSchema.statics.findByTrackingNumber = function(trackingNumber: string) {
  return this.findOne({ trackingNumber })
    .populate('userId', 'name email');
};

orderSchema.statics.getUserOrderSummary = async function(userId: string) {
  const totalOrders = await this.countDocuments({ userId });
  const pendingOrders = await this.countDocuments({ userId, status: OrderStatus.PENDING });
  const completedOrders = await this.countDocuments({ userId, status: OrderStatus.DELIVERED });
  
  const totalSpent = await this.aggregate([
    { $match: { userId: mongoose.Types.ObjectId(userId), paymentStatus: PaymentStatus.PAID } },
    { $group: { _id: null, total: { $sum: '$totalAmount' } } }
  ]);
  
  return {
    totalOrders,
    pendingOrders,
    completedOrders,
    totalSpent: totalSpent[0]?.total || 0,
    formattedTotalSpent: `₹${(totalSpent[0]?.total || 0).toFixed(2)}`
  };
};

orderSchema.statics.updateStatus = function(orderId: string, status: OrderStatus, trackingNumber?: string) {
  const updateData: any = { status };
  if (trackingNumber) updateData.trackingNumber = trackingNumber;
  
  return this.findByIdAndUpdate(orderId, updateData, { new: true });
};

orderSchema.statics.updatePaymentStatus = function(orderId: string, paymentStatus: PaymentStatus, paymentId?: string) {
  const updateData: any = { paymentStatus };
  if (paymentId) updateData.paymentId = paymentId;
  
  return this.findByIdAndUpdate(orderId, updateData, { new: true });
};

export const Order = mongoose.model<IOrder>('Order', orderSchema);