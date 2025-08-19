import { Server, Socket } from 'socket.io';
import { verifyAccessToken } from '@/utils/tokenUtils';
import { User } from '@/models/User';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  user?: any;
}

/**
 * Socket.IO service for real-time features
 * Handles user connections, authentication, and real-time events
 */
export const setupSocketIO = (io: Server) => {
  // Middleware for socket authentication
  io.use(async (socket: AuthenticatedSocket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');
      
      if (token) {
        const decoded = verifyAccessToken(token);
        const user = await User.findById(decoded.userId);
        
        if (user && user.isActive) {
          socket.userId = user.id;
          socket.user = user;
          console.log(`🔌 User ${user.name} (${user.id}) connected via Socket.IO`);
        }
      }
      
      next();
    } catch (error) {
      console.log('❌ Socket authentication failed:', error);
      // Allow connection even without auth for public events
      next();
    }
  });

  // Handle client connections
  io.on('connection', (socket: AuthenticatedSocket) => {
    console.log(`📱 Client connected: ${socket.id}${socket.userId ? ` (User: ${socket.userId})` : ' (Anonymous)'}`);

    // Join user to their personal room for targeted notifications
    if (socket.userId) {
      socket.join(`user:${socket.userId}`);
      socket.join('authenticated-users');
      
      // Send welcome message to authenticated user
      socket.emit('welcome', {
        message: `Welcome ${socket.user?.name}! You're now connected to real-time updates.`,
        timestamp: new Date().toISOString()
      });
    } else {
      socket.join('anonymous-users');
    }

    // Join general rooms
    socket.join('all-users');

    // Handle cart updates
    socket.on('cart:join', () => {
      if (socket.userId) {
        socket.join(`cart:${socket.userId}`);
        console.log(`🛒 User ${socket.userId} joined cart updates`);
      }
    });

    socket.on('cart:leave', () => {
      if (socket.userId) {
        socket.leave(`cart:${socket.userId}`);
        console.log(`🛒 User ${socket.userId} left cart updates`);
      }
    });

    // Handle wishlist updates
    socket.on('wishlist:join', () => {
      if (socket.userId) {
        socket.join(`wishlist:${socket.userId}`);
        console.log(`❤️ User ${socket.userId} joined wishlist updates`);
      }
    });

    socket.on('wishlist:leave', () => {
      if (socket.userId) {
        socket.leave(`wishlist:${socket.userId}`);
        console.log(`❤️ User ${socket.userId} left wishlist updates`);
      }
    });

    // Handle order updates
    socket.on('orders:join', () => {
      if (socket.userId) {
        socket.join(`orders:${socket.userId}`);
        console.log(`📦 User ${socket.userId} joined order updates`);
      }
    });

    socket.on('orders:leave', () => {
      if (socket.userId) {
        socket.leave(`orders:${socket.userId}`);
        console.log(`📦 User ${socket.userId} left order updates`);
      }
    });

    // Handle product updates subscription
    socket.on('products:subscribe', (productIds: string[]) => {
      if (Array.isArray(productIds)) {
        productIds.forEach(productId => {
          socket.join(`product:${productId}`);
        });
        console.log(`📱 Client ${socket.id} subscribed to product updates:`, productIds);
      }
    });

    socket.on('products:unsubscribe', (productIds: string[]) => {
      if (Array.isArray(productIds)) {
        productIds.forEach(productId => {
          socket.leave(`product:${productId}`);
        });
        console.log(`📱 Client ${socket.id} unsubscribed from product updates:`, productIds);
      }
    });

    // Handle ping/pong for connection health
    socket.on('ping', () => {
      socket.emit('pong', { timestamp: new Date().toISOString() });
    });

    // Handle client disconnect
    socket.on('disconnect', (reason) => {
      console.log(`📱 Client disconnected: ${socket.id} (${reason})${socket.userId ? ` - User: ${socket.userId}` : ''}`);
    });

    // Handle errors
    socket.on('error', (error) => {
      console.error(`❌ Socket error for ${socket.id}:`, error);
    });
  });

  return io;
};

/**
 * Emit real-time updates to specific users or rooms
 */
export class SocketEmitter {
  constructor(private io: Server) {}

  // Cart notifications
  emitCartUpdate(userId: string, data: any) {
    this.io.to(`cart:${userId}`).emit('cart:updated', {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  emitCartItemAdded(userId: string, item: any) {
    this.io.to(`cart:${userId}`).emit('cart:item-added', {
      item,
      timestamp: new Date().toISOString()
    });
  }

  emitCartItemRemoved(userId: string, itemId: string) {
    this.io.to(`cart:${userId}`).emit('cart:item-removed', {
      itemId,
      timestamp: new Date().toISOString()
    });
  }

  emitCartCleared(userId: string) {
    this.io.to(`cart:${userId}`).emit('cart:cleared', {
      timestamp: new Date().toISOString()
    });
  }

  // Wishlist notifications
  emitWishlistUpdate(userId: string, data: any) {
    this.io.to(`wishlist:${userId}`).emit('wishlist:updated', {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  emitWishlistItemAdded(userId: string, item: any) {
    this.io.to(`wishlist:${userId}`).emit('wishlist:item-added', {
      item,
      timestamp: new Date().toISOString()
    });
  }

  emitWishlistItemRemoved(userId: string, itemId: string) {
    this.io.to(`wishlist:${userId}`).emit('wishlist:item-removed', {
      itemId,
      timestamp: new Date().toISOString()
    });
  }

  // Order notifications
  emitOrderCreated(userId: string, order: any) {
    this.io.to(`orders:${userId}`).emit('order:created', {
      order,
      timestamp: new Date().toISOString()
    });
  }

  emitOrderStatusUpdate(userId: string, orderId: string, status: string, trackingNumber?: string) {
    this.io.to(`orders:${userId}`).emit('order:status-updated', {
      orderId,
      status,
      trackingNumber,
      timestamp: new Date().toISOString()
    });
  }

  emitPaymentUpdate(userId: string, orderId: string, paymentStatus: string, paymentId?: string) {
    this.io.to(`orders:${userId}`).emit('payment:status-updated', {
      orderId,
      paymentStatus,
      paymentId,
      timestamp: new Date().toISOString()
    });
  }

  // Product notifications
  emitProductUpdate(productId: string, updateType: 'stock' | 'price' | 'availability', data: any) {
    this.io.to(`product:${productId}`).emit('product:updated', {
      productId,
      updateType,
      data,
      timestamp: new Date().toISOString()
    });
  }

  emitProductStockUpdate(productId: string, newStock: number) {
    this.io.to(`product:${productId}`).emit('product:stock-updated', {
      productId,
      newStock,
      timestamp: new Date().toISOString()
    });
  }

  emitProductPriceUpdate(productId: string, newPrice: number) {
    this.io.to(`product:${productId}`).emit('product:price-updated', {
      productId,
      newPrice,
      formattedPrice: `₹${newPrice.toFixed(2)}`,
      timestamp: new Date().toISOString()
    });
  }

  // General notifications
  emitNotification(userId: string, notification: any) {
    this.io.to(`user:${userId}`).emit('notification', {
      ...notification,
      timestamp: new Date().toISOString()
    });
  }

  emitBroadcast(event: string, data: any) {
    this.io.to('all-users').emit(event, {
      ...data,
      timestamp: new Date().toISOString()
    });
  }

  // System notifications
  emitMaintenanceNotification(message: string, scheduledTime?: Date) {
    this.io.to('all-users').emit('system:maintenance', {
      message,
      scheduledTime,
      timestamp: new Date().toISOString()
    });
  }

  emitPromotionNotification(promotion: any) {
    this.io.to('authenticated-users').emit('promotion:new', {
      promotion,
      timestamp: new Date().toISOString()
    });
  }
}