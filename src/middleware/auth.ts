import { Request, Response, NextFunction } from 'express';
import { User } from '@/models/User';
import { AppError } from '@/utils/AppError';
import { catchAsync } from '@/utils/catchAsync';
import { verifyAccessToken } from '@/utils/tokenUtils';

interface AuthRequest extends Request {
  user?: any;
}

/**
 * Middleware to authenticate users using JWT tokens
 * Expects Authorization header with format: "Bearer <token>"
 */
export const authenticate = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  // Get token from header
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new AppError('Authentication token is required. Please provide a valid Bearer token.', 401));
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return next(new AppError('Authentication token is required', 401));
  }

  try {
    // Verify token
    const decoded = verifyAccessToken(token);

    // Check if user still exists
    const user = await User.findById(decoded.userId);
    if (!user) {
      return next(new AppError('The user belonging to this token no longer exists', 401));
    }

    // Check if user account is active
    if (!user.isActive) {
      return next(new AppError('Your account has been deactivated. Please contact support.', 401));
    }

    // Grant access to protected route
    req.user = user;
    next();
  } catch (error: any) {
    return next(error);
  }
});

/**
 * Middleware to check if user is authenticated (optional authentication)
 * Sets req.user if valid token is provided, but doesn't fail if no token
 */
export const optionalAuth = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  
  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.split(' ')[1];
    
    if (token) {
      try {
        const decoded = verifyAccessToken(token);
        const user = await User.findById(decoded.userId);
        
        if (user && user.isActive) {
          req.user = user;
        }
      } catch (error) {
        // Ignore errors for optional auth
      }
    }
  }
  
  next();
});

/**
 * Middleware to restrict access to certain roles
 * Note: This is a placeholder for role-based access control
 * The current User model doesn't include roles, but this can be extended
 */
export const restrictTo = (...roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    // For now, all authenticated users have access
    // This can be extended when roles are added to the User model
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    // Placeholder for role checking
    // if (!roles.includes(req.user.role)) {
    //   return next(new AppError('You do not have permission to perform this action', 403));
    // }

    next();
  };
};

/**
 * Middleware to ensure user owns the resource or is admin
 * Checks if the user ID in the token matches the resource owner
 */
export const ensureOwnership = (userIdField: string = 'userId') => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AppError('Authentication required', 401));
    }

    const resourceUserId = req.params[userIdField] || req.body[userIdField];
    
    if (resourceUserId && resourceUserId !== req.user.id) {
      return next(new AppError('You can only access your own resources', 403));
    }

    next();
  };
};

/**
 * Middleware to check if user ID in params matches authenticated user
 * Commonly used for user-specific endpoints like /api/users/:userId/cart
 */
export const validateUserAccess = catchAsync(async (req: AuthRequest, res: Response, next: NextFunction) => {
  const { userId } = req.params;
  
  if (!req.user) {
    return next(new AppError('Authentication required', 401));
  }

  if (userId && userId !== req.user.id) {
    return next(new AppError('You can only access your own data', 403));
  }

  next();
});